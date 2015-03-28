require 'rubygems'
require 'em-hiredis'

require 'workqueue/runner'
require 'workqueue/task'
require 'workqueue/task_serializer'
require 'workqueue/task_sink'
require 'workqueue/task_source'

# Provide a short alias
WQ = WorkQueue
