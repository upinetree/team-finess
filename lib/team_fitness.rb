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
    @pull_requests = []
  end

  def fetch
    # TODO: fetched_atを記憶しておいて、差分だけ取るようにする
    # TODO: pull_requetsはパースした上で格納する
    # 分析対象は現状closedのみ
    pull_requests = @client.pull_requests(@repo_name, :closed)

    pull_requests.each do |pr|
      comments = Comment.parse_all(pr.rels[:comments].get.data, :pull_request)
      comments.concat Comment.parse_all(pr.rels[:review_comments].get.data, :review)

      commits = pr.rels[:commits].get.data
      commit_comments = commits.map do |commit|
        Comment.parse_all(commit.rels[:comments].get.data, :commit)
      end.flatten
      comments.concat commit_comments

      pr.comments = comments
    end

    @pull_requests.concat pull_requests
  end

  def comments
    @pull_requests.map(&:comments).flatten
  end

  def comments_with_pr_number
    @pull_requests.map do |pr|
      pr.comments.product [pr.number]
    end.flatten(1)
  end

  def export_to(filename)
    CSV.open(filename + '.comments.csv', 'w') do |csv|
      comments_with_pr_number.each do |comment, number|
        csv << [
          comment.type,
          comment.id,
          comment.body,
          comment.user,
          comment.created_at,
          number
        ]
      end
    end

    CSV.open(filename + '.pulls.csv', 'w') do |csv|
      @pull_requests.each do |pr|
        csv << [
          pr.number,
          pr.state,
          pr.title,
          pr.user,
          pr.body,
          pr.created_at,
          pr.closed_at
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
        Comment.new(type, resource)
      end
    end

    attr_reader :type, :id, :body, :user, :created_at

    def initialize(type, resource)
      @type = type
      @id   = resource.id
      @body = resource.body
      @user = resource.user.login
      @created_at = resource.created_at
    end
  end

  class PullRequest
    class << self
      def parse_all(resources)
        resources.map{ |pr| PullRequest.new(pr) }
      end
   end

    attr_reader :number, :state, :title, :user, :body, :created_at, :closed_at
    attr_accessor :comments

    def initialize(resource)
      @number = resource.number
      @state = resource.state
      @title = resource.title
      @user = resource.user.login
      @body = resource.body
      @created_at = resource.created_at
      @closed_at = resource.closed_at
      @comments = []
    end
  end
end
