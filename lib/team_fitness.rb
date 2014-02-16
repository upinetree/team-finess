require 'octokit'
require 'csv'

class TeamFitness
  def initialize(repo_name = nil)
    @client = Octokit::Client.new netrc: true
    @client.auto_paginate = true
    @client.per_page = 100
    # auto_paginateが優先される。コメント取得のために設定
    # TODO: コメントが最大100件を超えるケースが多い場合は
    #       全て取得するように変更する（参考: Octokit::Client#paginate）

    @repo_name = repo_name
    @comments = []
    @pull_requests = []
  end

  def update
    # TODO: updated_atを記憶しておいて、差分だけ取るようにする
    @pull_requests.concat @client.pull_requests(@repo_name)

    new_comments = @pull_requests.map do |pr|
      comments = Comment.parse_all(pr.rels[:comments].get.data, :pull_request)
      comments.concat Comment.parse_all(pr.rels[:review_comments].get.data, :review)

      commits = pr.rels[:commits].get.data
      commit_comments = commits.map do |commit|
        Comment.parse_all(commit.rels[:comments].get.data, :commit)
      end.flatten
      comments.concat commit_comments

      comments
    end.flatten

    @comments.concat new_comments
  end

  def comments
    @comments
  end

  def export_to(filename)
    CSV.open(filename, 'w') do |csv|
      @comments.each do |comment|
        csv << [
          comment.type,
          comment.id,
          comment.body
          ]
      end
    end
  end

  class Comment
    class << self
      def parse_all(resources, type)
        resources.map{ |comment| Comment.parse(comment, type) }
      end

      def parse(resource, type)
        Comment.new(type, id: resource.id, body: resource.body)
      end
    end

    attr_reader :type, :id, :body

    def initialize(type, id: nil, body: '')
      @type = type
      @id = id
      @body = body
    end
  end
end
