require 'rails_helper'
describe API::SearchController do

  let(:user)    { create :user }
  let(:group)   { create :group }
  let(:discussion) { create :discussion, group: group }
  let(:motion) { create :current_motion, discussion: discussion }
  let(:comment) { create :comment, discussion: discussion }

  describe 'index' do
    before do
      group.admins << user
      sign_in user
    end

    it 'does not find irrelevant threads' do
      json = search_for('find')
      result_keys = fields_for(json, 'search_results', 'key')
      expect(result_keys).to_not include discussion.key
    end

    it "can find a discussion by title" do
      DiscussionService.update discussion: discussion, params: { title: 'find me' }, actor: user
      search_for('find')

      expect(@result_keys).to include discussion.key
      expect(@ranks).to include SearchVector::WEIGHT_VALUES[3]
    end

    it "can find a discussion by description" do
      DiscussionService.update discussion: discussion, params: { description: 'find me' }, actor: user
      search_for('find')

      expect(@result_keys).to include discussion.key
      expect(@ranks).to include SearchVector::WEIGHT_VALUES[1]
    end

    it "can find a discussion by proposal name" do
      motion.update name: 'find me'
      SearchVector.index! motion.discussion_id
      search_for('find')

      expect(@result_keys).to include discussion.key
      expect(@ranks).to include SearchVector::WEIGHT_VALUES[2]
    end

    it "can find a discussion by proposal description" do
      motion.update description: 'find me'
      SearchVector.index! motion.discussion_id
      search_for('find')

      expect(@result_keys).to include discussion.key
      expect(@ranks).to include SearchVector::WEIGHT_VALUES[1]
    end

    it "can find a discussion by comment body" do
      comment.update body: 'find me'
      SearchVector.index! comment.discussion_id
      result = search_for('find')
      expect(@result_keys).to include discussion.key
      expect(@ranks).to include SearchVector::WEIGHT_VALUES[0]
    end

    it "does not display content the user does not have access to" do
      DiscussionService.update discussion: discussion, params: { group: create(:group) }, actor: user
      search_for('find')

      expect(@result_keys).to_not include discussion.key
    end
  end
end

def fields_for(json, name, field)
  return [] unless json[name]
  json[name].map { |f| f[field] }
end

def search_for(term)
  get :index, q: term, format: :json
  JSON.parse(response.body).tap do |json|
    expect(json.keys).to include *(%w[search_results])
    @result_keys = fields_for(json, 'search_results', 'key')
    @ranks      = fields_for(json, 'search_results', 'rank').map(&:to_f)
  end
end
