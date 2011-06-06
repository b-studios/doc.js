# Load CodeObject::Types
require_relative 'types/prototype'

# Load Default Tokens
require_relative 'tokens/tokens'

# Register Rendertasks
require_relative 'tasks/typed_task'
require_relative 'tasks/docs_task'
require_relative 'tasks/api_index_task'
require_relative 'tasks/json_data_task'

# Register Helpers
require_relative 'helpers/template'