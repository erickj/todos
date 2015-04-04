require 'rubygems'
require 'em-hiredis'

require 'logging'

require 'workqueue/event_emitter'
require 'workqueue/publisher'
require 'workqueue/runner'
require 'workqueue/task'
require 'workqueue/task_result'
require 'workqueue/task_serializer'
require 'workqueue/handler'
require 'workqueue/task_sink'
require 'workqueue/task_source'

# Provide a short alias
WQ = WorkQueue

module WQ
  TASK_RESULT_CHANNEL = :wq_task_results
end
