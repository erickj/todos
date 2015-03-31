require 'rubygems'
require 'em-hiredis'

require 'workqueue/event_emitter'
require 'workqueue/runner'
require 'workqueue/task'
require 'workqueue/task_serializer'
require 'workqueue/handler'
require 'workqueue/task_sink'
require 'workqueue/task_source'

# Provide a short alias
WQ = WorkQueue
