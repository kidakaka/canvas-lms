#
# Copyright (C) 2011 Instructure, Inc.
#
# This file is part of Canvas.
#
# Canvas is free software: you can redistribute it and/or modify it under
# the terms of the GNU Affero General Public License as published by the Free
# Software Foundation, version 3 of the License.
#
# Canvas is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. See the GNU Affero General Public License for more
# details.
#
# You should have received a copy of the GNU Affero General Public License along
# with this program. If not, see <http://www.gnu.org/licenses/>.
#

module Api::V1::DiscussionTopics
  include Api
  
  def discussion_topic_api_json(topics)
    topics.map do |topic|

      attachments = []
      if topic.attachment
        attachments << attachment_json(topic.attachment, :context => @context)
      end

      url = nil
      if topic.podcast_enabled
        code = @context_enrollment ? @context_enrollment.feed_code : @context.feed_code
        url = feeds_topic_format_path(topic.id, code, :rss)
      end

      children = topic.child_topics.scoped(:select => 'id').map(&:id)

      topic.as_json(:include_root => false,
                    :only => %w(id title assignment_id delayed_post_at last_reply_at message posted_at require_initial_post root_topic_id),
                    :methods => [:user_name, :discussion_subentry_count],
                    :permissions => {:user => @current_user, :session => session}
      ).tap do |json|
        json.merge! :podcast_url => url,
                    :topic_children => children,
                    :attachments => attachments
      end
    end
  end

  def topic_pagination_path
    if @context.is_a? Course
      api_v1_course_discussion_topics_path(@context)
    else
      api_v1_group_discussion_topics_path(@context)
    end
  end
end
