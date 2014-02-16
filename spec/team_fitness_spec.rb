require 'spec_helper'

describe TeamFitness do
  describe '#comments' do
    let(:repo_name) { 'upinetree/github-api-test' }
    let(:team_fitness) { TeamFitness.new(repo_name) }
    
    before do
      team_fitness.fetch
    end

    context 'without option' do
      subject { team_fitness.comments }
      it "has correct comments" do
        should have(6).comments

        comment = subject.first
        comment.id.should_not be_nil
        comment.body.should_not be_nil
        comment.user.should_not be_nil
        comment.created_at.should_not be_nil
      end
    end
  end
end
