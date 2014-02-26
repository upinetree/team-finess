require 'octokit'
require 'csv'

class TeamFitness
  attr_reader :pull_requests, :comments

  def initialize(repo_name = nil)
    @client = Octokit::Client.new netrc: true
    @client.auto_paginate = true
    @client.per_page = 100
    # auto_paginateが優先される。コメント取得のために設定
    # TODO: コメントが最大100件を超えるケースが多い場合は
    #       全て取得するように変更する（参考: Octokit::Client#paginate）

    @repo_name = repo_name
    @pull_requests = []
    @comments = []
  end

  def fetch
    # TODO: fetched_atを記憶しておいて、差分だけ取るようにする
    # TODO: pull_requetsはパースした上で格納する
    # 分析対象は現状closedのみ
    pr_resources = @client.pull_requests(@repo_name, :closed)

    pr_resources.each do |pr_resource|
      @pull_requests << PullRequest.parse(pr_resource)

      @comments.concat parse_pull_request_comments(pr_resource)
      @comments.concat parse_files_changed_comments(pr_resource)
      @comments.concat parse_commit_comments(pr_resource)
    end
  end

  def export_cvs(to: 'out')
    comments_filename = to + '.comments.csv'
    pulls_filename    = to + '.pulls.csv'

    CSV.open(comments_filename, 'w') do |csv|
      @comments.each do |comment|
        csv << [
          comment.id,
          comment.type,
          comment.body,
          comment.user,
          comment.created_at,
          comment.pr_number
        ]
      end
    end

    CSV.open(pulls_filename, 'w') do |csv|
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

  def import_cvs(from: 'out')
    pulls_filename    = from + '.pulls.csv'
    comments_filename = from + '.comments.csv'

    CSV.foreach(comments_filename) do |row|
      keys = %w|type id body user created_at pr_number|.map(&:to_sym)
      attrs = Hash[keys.zip(row)]
      @comments << Comment.new(attrs)
    end

    CSV.foreach(pulls_filename) do |row|
      keys = %w|number state title user body created_at closed_at|.map(&:to_sym)
      attrs = Hash[keys.zip(row)]
      @pull_requests << PullRequest.new(attrs)
    end
  end

  private

  def parse_pull_request_comments(pr_resource)
    Comment.parse_all(pr_resource.rels[:comments].get.data, :pull_request, pr_resource.number)
  end

  def parse_files_changed_comments(pr_resource)
    Comment.parse_all(pr_resource.rels[:review_comments].get.data, :files_changed, pr_resource.number)
  end

  def parse_commit_comments(pr_resource)
    commits = pr_resource.rels[:commits].get.data
    commit_comments = commits.map do |commit|
      Comment.parse_all(commit.rels[:comments].get.data, :commit, pr_resource.number)
    end.flatten
  end

  class Comment
    class << self
      def parse_all(resources, type, pr_number)
        resources.map{ |comment| self.parse(comment, type, pr_number) }
      end

      def parse(resource, type, pr_number)
        attrs = {
          type: type,
          id: resource.id,
          body: resource.body,
          user: resource.user.login,
          created_at: resource.created_at,
          pr_number: pr_number
        }
        self.new(attrs)
      end
    end

    attr_reader :type, :id, :body, :user, :created_at, :pr_number

    def initialize(attrs)
      @type = attrs[:type]
      @id   = attrs[:id]
      @body = attrs[:body]
      @user = attrs[:user]
      @created_at = attrs[:created_at]
      @pr_number = attrs[:pr_number]
    end
  end

  class PullRequest
    class << self
      def parse(resource)
        attrs = {
          number: resource.number,
          state: resource.state,
          title: resource.title,
          user: resource.user.login,
          body: resource.body,
          created_at: resource.created_at,
          closed_at: resource.closed_at
        }
        self.new(attrs)
      end
    end

    attr_reader :number, :state, :title, :user, :body, :created_at, :closed_at

    def initialize(attrs)
      @number = attrs[:number]
      @state = attrs[:state]
      @title = attrs[:title]
      @user = attrs[:user]
      @body = attrs[:body]
      @created_at = attrs[:created_at]
      @closed_at = attrs[:closed_at]
    end
  end
end
