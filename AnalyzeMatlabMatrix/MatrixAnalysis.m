clear
run('MatrixData.m');
run('Globals.m')
tensor_arena = 0x00000000;
tensor_arena_size= 4*1024;


tensor_head = tensor_arena;
tensor_tail = tensor_head + tensor_arena_size;

model_matrix_direction = 0x0804992C;
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
            pointer_to_subgraph = GetPointer(VT_SUBGRAPHS, model_direction, offsetmatrixmodel, g_model, model_matrix_direction);
            fprintf('Subgraph direction is 0x%s\n', dec2hex(pointer_to_subgraph));
            
            % Information about the subgraph: 
        % The subgraph has its own VTABLE
        % Let's break it down
        % Before this, we got a pointer to subgraph
        % On that location we find in this order: size of the subgraph (4
        % bytes), offset the the i-th subgraph (we only have one)
        % To get the data_ for that vtable we do sugraphs+4(size)+offset
        
        subgraph.size = getnumber(g_model(pointer_to_subgraph-model_matrix_direction+1),g_model(pointer_to_subgraph-model_matrix_direction+2));
        %subgraph.vtable = pointer_to_subgraph -  



