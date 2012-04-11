module Patches
  module MyControllerPatch

    def self.included(base)
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)
      base.class_eval do
        unloadable
        alias_method_chain :account, :ext
      end
    end

    module ClassMethods
    end

    module InstanceMethods

      def account_with_ext
        if request.post?
          User.current.pref[:no_self_notified_closed] = (params[:no_self_notified_closed] == '1')
        end
        account_without_ext
      end

    end

  end
end