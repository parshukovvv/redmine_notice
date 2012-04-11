module Patches
  module IssuePatch

    def self.included(base)
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)
      base.class_eval do
        unloadable
        alias_method :recipients, :recipients_ext
        alias_method :watcher_recipients, :watcher_recipients_ext
      end
    end

    module ClassMethods
    end

    module InstanceMethods

      def recipients_ext
        @status = IssueStatus.find_by_id(self.status_id)

        notified = project.notified_users
        # Author and assignee are always notified unless they have been
        # locked or don't want to be notified
        notified << author if author && author.active? && author.notify_about?(self) && allow_notify_closed?(author)
        if assigned_to
          if assigned_to.is_a?(Group)
            notified += assigned_to.users.select { |u| u.active? && u.notify_about?(self) && allow_notify_closed?(u) }
          else
            notified << assigned_to if assigned_to.active? && assigned_to.notify_about?(self) && allow_notify_closed?(assigned_to)
          end
        end
        notified.uniq!
        # Remove users that can not view the issue
        notified.reject! { |user| !visible?(user) }
        notified.collect(&:mail)
      end

      def watcher_recipients_ext
        notified = watcher_users.active
        notified.reject! { |user| user.mail_notification == 'none' || allow_notify_closed?(user) === false }

        if respond_to?(:visible?)
          notified.reject! { |user| !visible?(user) }
        end
        notified.collect(&:mail).compact
      end

      private

      # check user pref and status closed
      def allow_notify_closed?(user)
        (user.pref[:no_self_notified_closed] && @status.is_closed?) ? false : true
      end

    end

  end
end