clear
run('MatrixData.m');
run('Globals.m')
tensor_arena = 0x00000000;
tensor_arena_size= 4*1024;


tensor_head = tensor_arena;
tensor_tail = tensor_head + tensor_arena_size;

model_matrix_direction = 0x08049B00;
model_direction = model_matrix_direction + getnumber(g_model(1),g_model(2));
offsetmatrixmodel = getnumber(g_model(1),g_model(2));

fprintf('Model matrix direction is 0x%s\n', dec2hex(model_matrix_direction));
fprintf('Model direction is 0x%s\n', dec2hex(model_direction));
fprintf('Tensor head direction is 0x%s\n', dec2hex(tensor_head));
fprintf('Tensor tail direction is 0x%s\n', dec2hex(tensor_tail));


% After that it declares de Ops Resolver, it doesn't have any effect

% Now it's turn for the interpreter

% Interpreter constructor

    % Allocator constructor
    
    % Aligns data
    aligned_arena = tensor_head; % If it doesn't have any alignment problem
    aligned_size = tensor_arena_size;
    % Declares the allocator with CreateInPlaceSimpleMemoryAllocator

        % CreateInPlaceSimpleMemoryAllocator

        % Declares a simple memory allocator
        buffer_head = aligned_arena;
        buffer_size = aligned_size;
        buffer_tail = aligned_arena + aligned_size;
        buffer_head_=buffer_head;
        buffer_tail_=buffer_tail;
        head_=buffer_head;
        tail_=buffer_tail;

        % Now it allocates from tail 
        tail_=allocatefromtail(tail_, sizeof_SimpleMemoryAllocator, alignof_SimpleMemoryAllocator);


        % Init function

        % Gets the number of subgraphs()
        % model->subgraphs() = GetPointer()

            % GetPointer calls GetOptionalFieldOffset
                
            % GetOptionalFieldOffset runs GetVtable

            % GetVtable
            pointer_to_subgraph = GetPointer(VT_MODEL.VT_SUBGRAPHS, model_direction, g_model, model_matrix_direction);
            fprintf('Subgraph direction is 0x%s\n', dec2hex(pointer_to_subgraph));
            
            % Information about the subgraph: 
        % The subgraph has its own VTABLE
        % Let's break it down
        % Before this, we got a pointer to subgraph
        % On that location we find in this order: size of the subgraph (4
        % bytes), offset the the i-th subgraph (we only have one)
        % To get the data_ for that vtable we do sugraphs+4(size)+offset
        
        subgraph.size = getnumber(g_model(pointer_to_subgraph-model_matrix_direction+1),g_model(pointer_to_subgraph-model_matrix_direction+2),g_model(pointer_to_subgraph-model_matrix_direction+3),g_model(pointer_to_subgraph-model_matrix_direction+4));
        subgraph.data_direction = pointer_to_subgraph + soffset_t_size + getnumber(g_model(pointer_to_subgraph-model_matrix_direction+soffset_t_size+1),g_model(pointer_to_subgraph-model_matrix_direction+soffset_t_size+2),g_model(pointer_to_subgraph-model_matrix_direction+soffset_t_size+3),g_model(pointer_to_subgraph-model_matrix_direction+soffset_t_size+4));  
        fprintf('Subgraph data direction is 0x%s\n', dec2hex(subgraph.data_direction));
        subgraph.tensor_pointer = GetPointer(VT_SUBGRAPHS.VT_TENSORS, subgraph.data_direction, g_model, model_matrix_direction);
        fprintf('Tensor direction is 0x%s\n', dec2hex(subgraph.tensor_pointer));  


%%  Getting model parameters
        
        % This works

        model.data_ = model_direction;
        model.vtable = model.data_ - getnumber(g_model(model.data_ - model_matrix_direction+1),g_model(model.data_ - model_matrix_direction+2));
        model.version = GetField(VT_MODEL.VT_VERSION, model.data_, g_model, model_matrix_direction,2,0);
        model.operator_codes = GetPointer(VT_MODEL.VT_OPERATOR_CODES, model_direction, g_model, model_matrix_direction);
        model.subgraphs = GetPointer(VT_MODEL.VT_SUBGRAPHS, model_direction, g_model, model_matrix_direction);
        model.description = GetPointer(VT_MODEL.VT_DESCRIPTION, model_direction, g_model, model_matrix_direction);
        model.buffers = GetPointer(VT_MODEL.VT_BUFFERS, model_direction, g_model, model_matrix_direction);
        model.metadata_buffer = GetPointer(VT_MODEL.VT_METADATA_BUFFER, model_direction, g_model, model_matrix_direction);
        model.metadata = GetPointer(VT_MODEL.VT_METADATA, model_direction, g_model, model_matrix_direction);

        fprintf(['model analysis:\n' ...
        '  data_: 0x%X\n' ...
        '  vtable: 0x%X\n' ...
        '  version: %d\n' ...
        '  operator_codes: 0x%X\n' ...
        '  subgraphs: 0x%X\n' ...
        '  description: 0x%X\n' ...
        '  buffers: 0x%X\n' ...
        '  metadata_buffer: 0x%X\n' ...
        '  metadata: 0x%X\n'], ...
        model.data_, ...
        model.vtable, ...
        model.version, ...
        model.operator_codes, ...
        model.subgraphs, ...
        model.description, ...
        model.buffers, ...
        model.metadata_buffer, ...
        model.metadata);
        
%%  Getting operator codes


operator_codes.size = getnumber(g_model(model.operator_codes-model_matrix_direction+1),g_model(model.operator_codes-model_matrix_direction+2),g_model(model.operator_codes-model_matrix_direction+3),g_model(model.operator_codes-model_matrix_direction+4))

for i=1:operator_codes.size
    operator_codes.operator(i).pointer=model.operator_codes + soffset_t_size*i + getnumber(g_model(model.operator_codes-model_matrix_direction+soffset_t_size*i+1),g_model(model.operator_codes-model_matrix_direction+soffset_t_size*i+2),g_model(model.operator_codes-model_matrix_direction+soffset_t_size*i+3),g_model(model.operator_codes-model_matrix_direction+soffset_t_size*i+4)) ;
    fprintf('Operator codes pointer 0x%s\n', dec2hex(operator_codes.operator(i).pointer));  
end
for i=1:operator_codes.size
    operator_codes.operator(i).builtin_code=GetField(VT_OPERATORS.VT_BUILTIN_CODE, operator_codes.operator(i).pointer, g_model, model_matrix_direction,1,0);
    operator_codes.operator(i).version=GetField(VT_OPERATORS.VT_VERSION, operator_codes.operator(i).pointer, g_model, model_matrix_direction,2,1);
    operator_codes.operator(i).custom_code = GetPointer(VT_OPERATORS.VT_CUSTOM_CODE, operator_codes.operator(i).pointer, g_model, model_matrix_direction);

end
       