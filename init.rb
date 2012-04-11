require 'redmine'

Redmine::Plugin.register :redmine_notice do
  name 'Redmine Notice plugin'
  author 'Vladimir Parshukov'
  description 'This plugin allows you to disable the notification of the closed tasks'
  version '1.0.0'
  url 'https://github.com/parshukovvv/redmine_notify'
  author_url ''
  requires_redmine :version_or_higher => '1.3.0'
end

require 'dispatcher'

Dispatcher.to_prepare do
  MyController.send(:include, Patches::MyControllerPatch)
  UsersController.send(:include, Patches::UsersControllerPatch)
  Issue.send(:include, Patches::IssuePatch)
end