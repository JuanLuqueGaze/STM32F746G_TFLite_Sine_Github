clear
run('MatrixData.m');
run('Globals.m')
tensor_arena = 0x200008C0;
tensor_arena_size= 4*1024;


tensor_head = tensor_arena;
tensor_tail = tensor_head + tensor_arena_size;

model_matrix_direction = 0x0804B1B4;
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


operator_codes.size = getnumber(g_model(model.operator_codes-model_matrix_direction+1),g_model(model.operator_codes-model_matrix_direction+2),g_model(model.operator_codes-model_matrix_direction+3),g_model(model.operator_codes-model_matrix_direction+4));

for i=1:operator_codes.size
    operator_codes.operator(i).pointer=model.operator_codes + soffset_t_size*i + getnumber(g_model(model.operator_codes-model_matrix_direction+soffset_t_size*i+1),g_model(model.operator_codes-model_matrix_direction+soffset_t_size*i+2),g_model(model.operator_codes-model_matrix_direction+soffset_t_size*i+3),g_model(model.operator_codes-model_matrix_direction+soffset_t_size*i+4));
    fprintf('Operator codes pointer 0x%s\n', dec2hex(operator_codes.operator(i).pointer));  
    operator_codes.operator(i).builtin_code=GetField(VT_OPERATORS.VT_BUILTIN_CODE, operator_codes.operator(i).pointer, g_model, model_matrix_direction,1,0);
    operator_codes.operator(i).version=GetField(VT_OPERATORS.VT_VERSION, operator_codes.operator(i).pointer, g_model, model_matrix_direction,2,1);
    operator_codes.operator(i).custom_code = GetPointer(VT_OPERATORS.VT_CUSTOM_CODE, operator_codes.operator(i).pointer, g_model, model_matrix_direction);
end

        fprintf(['operator codes analysis:\n' ...
        '  size: %d\n' ...   
        '  operator number 1:\n' ...
        '    builtin code: %d\n' ...
        '    custom code: 0x%X\n' ...
        '    version: %d\n' ...
        '  operator number 2:\n' ...
        '    builtin code: %d\n' ...
        '    custom code: 0x%X\n' ...
        '    version: %d\n' ...
        '  operator number 3:\n' ...
        '    builtin code: %d\n' ...
        '    custom code: 0x%X\n' ...
        '    version: %d\n'], ...
        operator_codes.size, ...
        operator_codes.operator(1).builtin_code, ...
        operator_codes.operator(1).custom_code, ...
        operator_codes.operator(1).version, ...
        operator_codes.operator(2).builtin_code, ...
        operator_codes.operator(2).custom_code, ...
        operator_codes.operator(2).version, ...
        operator_codes.operator(3).builtin_code, ...
        operator_codes.operator(3).custom_code, ...
        operator_codes.operator(3).version);
       
%%  Getting subgraph information


subgraph.size = getnumber(g_model(model.subgraphs-model_matrix_direction+1),g_model(model.subgraphs-model_matrix_direction+2),g_model(model.subgraphs-model_matrix_direction+3),g_model(model.subgraphs-model_matrix_direction+4));

%It only allows 1 subgraph
subgraph.direction=model.subgraphs + soffset_t_size + getnumber(g_model(model.subgraphs-model_matrix_direction+soffset_t_size+1),g_model(model.subgraphs-model_matrix_direction+soffset_t_size+2),g_model(model.subgraphs-model_matrix_direction+soffset_t_size+3),g_model(model.subgraphs-model_matrix_direction+soffset_t_size+4));
subgraph.tensors.direction = GetPointer(VT_SUBGRAPHS.VT_TENSORS, subgraph.direction, g_model, model_matrix_direction);
subgraph.inputs.direction = GetPointer(VT_SUBGRAPHS.VT_INPUTS, subgraph.direction, g_model, model_matrix_direction);
subgraph.outputs.direction = GetPointer(VT_SUBGRAPHS.VT_OUTPUTS, subgraph.direction, g_model, model_matrix_direction);
subgraph.operators.direction = GetPointer(VT_SUBGRAPHS.VT_OPERATORS, subgraph.direction, g_model, model_matrix_direction);
subgraph.name.direction = GetPointer(VT_SUBGRAPHS.VT_NAME, subgraph.direction, g_model, model_matrix_direction);

fprintf(['Subgraph analysis:\n' ...
        '  direction: 0x%X\n' ...
        '  size: %d\n' ...
        '  tensors direction: 0x%X\n' ...
        '  inputs direction: 0x%X\n' ...
        '  outputs direction: 0x%X\n' ...
        '  operators direction: 0x%X\n' ...
        '  name direction: 0x%X\n'], ...
        subgraph.direction, ...
        subgraph.size, ...
        subgraph.tensors.direction, ...
        subgraph.inputs.direction, ...
        subgraph.outputs.direction, ...
        subgraph.operators.direction, ...
        subgraph.name.direction);
        
%% Getting tensors inside of operator codes


subgraph.tensors.size = getnumber(g_model(subgraph.tensors.direction-model_matrix_direction+1),g_model(subgraph.tensors.direction-model_matrix_direction+2),g_model(subgraph.tensors.direction-model_matrix_direction+3),g_model(subgraph.tensors.direction-model_matrix_direction+4));


for i=1:subgraph.tensors.size
    subgraph.tensors.tensor(i).pointer=subgraph.tensors.direction + soffset_t_size*i + getnumber(g_model(subgraph.tensors.direction-model_matrix_direction+soffset_t_size*i+1),g_model(subgraph.tensors.direction-model_matrix_direction+soffset_t_size*i+2),g_model(subgraph.tensors.direction-model_matrix_direction+soffset_t_size*i+3),g_model(subgraph.tensors.direction-model_matrix_direction+soffset_t_size*i+4));
    subgraph.tensors.tensor(i).shape_pointer = GetPointer(VT_TENSORS.VT_SHAPE,subgraph.tensors.tensor(i).pointer, g_model, model_matrix_direction);
    fprintf('Tensor shape pointer of tensor %d is:  0x%s\n',i, dec2hex(subgraph.tensors.tensor(i).shape_pointer));  
    subgraph.tensors.tensor(i).type = GetField(VT_TENSORS.VT_TYPE,subgraph.tensors.tensor(i).pointer, g_model, model_matrix_direction,1,0);
    fprintf('Tensor type of tensor %d is:  %d\n',i, subgraph.tensors.tensor(i).type);
    subgraph.tensors.tensor(i).buffer = GetField(VT_TENSORS.VT_BUFFER,subgraph.tensors.tensor(i).pointer, g_model, model_matrix_direction,2,0);
    fprintf('Tensor buffer of tensor %d is:  %d\n',i, subgraph.tensors.tensor(i).buffer); 
    subgraph.tensors.tensor(i).name_pointer = GetPointer(VT_TENSORS.VT_NAME,subgraph.tensors.tensor(i).pointer, g_model, model_matrix_direction);
    fprintf('Tensor name pointer of tensor %d is:  0x%s\n',i, dec2hex(subgraph.tensors.tensor(i).name_pointer));  
    subgraph.tensors.tensor(i).quantization_pointer = GetPointer(VT_TENSORS.VT_QUANTIZATION,subgraph.tensors.tensor(i).pointer, g_model, model_matrix_direction);
    fprintf('Tensor quantization pointer of tensor %d is:  0x%s\n',i, dec2hex(subgraph.tensors.tensor(i).quantization_pointer));  
    subgraph.tensors.tensor(i).is_variable = GetField(VT_TENSORS.VT_IS_VARIABLE,subgraph.tensors.tensor(i).pointer, g_model, model_matrix_direction,2,0);
    fprintf('Tensor is_variable of tensor %d is:  %d\n',i, subgraph.tensors.tensor(i).is_variable); 
    subgraph.tensors.tensor(i).sparsity_pointer = GetPointer(VT_TENSORS.VT_SPARSITY,subgraph.tensors.tensor(i).pointer, g_model, model_matrix_direction);
    fprintf('Tensor sparsity pointer of tensor %d is:  0x%s\n',i, dec2hex(subgraph.tensors.tensor(i).sparsity_pointer));  
    subgraph.tensors.tensor(i).shape_signature_pointer = GetPointer(VT_TENSORS.VT_SHAPE_SIGNATURE,subgraph.tensors.tensor(i).pointer, g_model, model_matrix_direction);
    fprintf('Tensor shape signature pointer of tensor %d is:  0x%s\n',i, dec2hex(subgraph.tensors.tensor(i).shape_signature_pointer));  
    fprintf('\n');  

end

%% Getting inside of the tensor shape 
for i=1:subgraph.tensors.size
    subgraph.tensors.tensor(i).shape = GetVector(subgraph.tensors.tensor(i).shape_pointer,4,model_matrix_direction,g_model);
end

%% Getting inside of the tensor name
for i=1:subgraph.tensors.size
    subgraph.tensors.tensor(i).name = char(GetVector(subgraph.tensors.tensor(i).name_pointer,1,model_matrix_direction,g_model));
end

%% Getting inside of the tensor quantization parameters



for i=1:subgraph.tensors.size

        subgraph.tensors.tensor(i).quantization.min = GetPointer(VT_QUANTIZATION.VT_MIN,subgraph.tensors.tensor(i).quantization_pointer, g_model, model_matrix_direction);
    fprintf('Tensor min pointer of tensor %d is:  0x%s\n',i, dec2hex( subgraph.tensors.tensor(i).quantization.min));  
        subgraph.tensors.tensor(i).quantization.max = GetPointer(VT_QUANTIZATION.VT_MAX,subgraph.tensors.tensor(i).quantization_pointer, g_model, model_matrix_direction);
    fprintf('Tensor max pointer of tensor %d is:  0x%s\n',i, dec2hex( subgraph.tensors.tensor(i).quantization.max));  
    subgraph.tensors.tensor(i).quantization.scale = GetPointer(VT_QUANTIZATION.VT_SCALE,subgraph.tensors.tensor(i).quantization_pointer, g_model, model_matrix_direction);
    fprintf('Tensor scale pointer of tensor %d is:  0x%s\n',i, dec2hex( subgraph.tensors.tensor(i).quantization.scale));
        subgraph.tensors.tensor(i).quantization.zero_point = GetPointer(VT_QUANTIZATION.VT_ZERO_POINT,subgraph.tensors.tensor(i).quantization_pointer, g_model, model_matrix_direction);
    fprintf('Tensor zero point pointer of tensor %d is:  0x%s\n',i, dec2hex( subgraph.tensors.tensor(i).quantization.zero_point));  
        subgraph.tensors.tensor(i).quantization.details = GetPointer(VT_QUANTIZATION.VT_DETAILS,subgraph.tensors.tensor(i).quantization_pointer, g_model, model_matrix_direction);
    fprintf('Tensor details pointer of tensor %d is:  0x%s\n',i, dec2hex( subgraph.tensors.tensor(i).quantization.details));  
             subgraph.tensors.tensor(i).quantization.details_type = GetField(VT_QUANTIZATION.VT_DETAILS_TYPE,subgraph.tensors.tensor(i).quantization_pointer, g_model, model_matrix_direction,1,0);
    fprintf('Tensor details type of tensor %d is:  %d\n',i, subgraph.tensors.tensor(i).quantization.details_type);
              subgraph.tensors.tensor(i).quantization.quantized_dimension = GetField(VT_QUANTIZATION.VT_QUANTIZED_DIMENSION,subgraph.tensors.tensor(i).quantization_pointer, g_model, model_matrix_direction,4,0);
    fprintf('Tensor quantized dimension of tensor %d is:  %d\n',i, subgraph.tensors.tensor(i).quantization.quantized_dimension);
  
end

for i = 1:subgraph.tensors.size

   subgraph.tensors.tensor(i).quantization.scale_content = GetVector(subgraph.tensors.tensor(i).quantization.scale,4,model_matrix_direction,g_model);
   subgraph.tensors.tensor(i).quantization.zero_point_content = GetVector(subgraph.tensors.tensor(i).quantization.scale,8,model_matrix_direction,g_model);

end

%% Getting input and output

for i=1:subgraph.size
    subgraph.inputs.content = GetVector(subgraph.inputs.direction,4,model_matrix_direction,g_model);
    subgraph.outputs.content = GetVector(subgraph.outputs.direction,4,model_matrix_direction,g_model);
end



%% Getting subgraph operator


subgraph.operators.size = getnumber(g_model(subgraph.operators.direction-model_matrix_direction+1),g_model(subgraph.operators.direction-model_matrix_direction+2),g_model(subgraph.operators.direction-model_matrix_direction+3),g_model(subgraph.operators.direction-model_matrix_direction+4));

for i=1:subgraph.operators.size
    subgraph.operators.operator(i).pointer= subgraph.operators.direction + soffset_t_size*i + getnumber(g_model(subgraph.operators.direction-model_matrix_direction+soffset_t_size*i+1),g_model(subgraph.operators.direction-model_matrix_direction+soffset_t_size*i+2),g_model(subgraph.operators.direction-model_matrix_direction+soffset_t_size*i+3),g_model(subgraph.operators.direction-model_matrix_direction+soffset_t_size*i+4));
    fprintf('Operator codes pointer 0x%s\n', dec2hex(subgraph.operators.operator(i).pointer));  
    subgraph.operators.operator(i).op_code_index=GetField(VT_OPERATOR.VT_OPCODE_INDEX, subgraph.operators.operator(i).pointer, g_model, model_matrix_direction,4,0);
    fprintf('Op code index of operator %d is:  %d\n',i, subgraph.operators.operator(i).op_code_index);
    subgraph.operators.operator(i).inputs_pointer = GetPointer(VT_OPERATOR.VT_INPUTS,subgraph.operators.operator(i).pointer, g_model, model_matrix_direction);
    fprintf('Input pointer of operator %d is:  0x%s\n',i, dec2hex(subgraph.operators.operator(i).inputs_pointer));  
    subgraph.operators.operator(i).outputs_pointer = GetPointer(VT_OPERATOR.VT_OUTPUTS,subgraph.operators.operator(i).pointer, g_model, model_matrix_direction);
    fprintf('Output pointer of operator %d is:  0x%s\n',i, dec2hex(subgraph.operators.operator(i).outputs_pointer));  
    subgraph.operators.operator(i).builtin_options_type = GetField(VT_OPERATOR.VT_BUILTIN_OPTIONS_TYPE,subgraph.operators.operator(i).pointer, g_model, model_matrix_direction,1,0);
    fprintf('Builtin type of operator %d is:  %d\n',i, subgraph.operators.operator(i).builtin_options_type);  
    subgraph.operators.operator(i).builtin_options_pointer = GetPointer(VT_OPERATOR.VT_BUILTIN_OPTIONS,subgraph.operators.operator(i).pointer, g_model, model_matrix_direction);
    fprintf('Builtin options pointer of operator %d is:  0x%s\n',i, dec2hex(subgraph.operators.operator(i).builtin_options_pointer));  
    subgraph.operators.operator(i).custom_options_pointer = GetPointer(VT_OPERATOR.VT_CUSTOM_OPTIONS,subgraph.operators.operator(i).pointer, g_model, model_matrix_direction);
    fprintf('Custom options pointer of operator %d is:  0x%s\n',i, dec2hex(subgraph.operators.operator(i).custom_options_pointer));  
    subgraph.operators.operator(i).custom_options_format = GetField(VT_OPERATOR.VT_CUSTOM_OPTIONS_FORMAT,subgraph.operators.operator(i).pointer, g_model, model_matrix_direction,1,0);
    fprintf('Custom options format of operator %d is:  %d\n',i, subgraph.operators.operator(i).custom_options_format);  
    subgraph.operators.operator(i).mutating_variable_inputs_pointer = GetPointer(VT_OPERATOR.VT_MUTATING_VARIABLE_INPUTS,subgraph.operators.operator(i).pointer, g_model, model_matrix_direction);
    fprintf('Mutating variable inputs pointer of operator %d is:  0x%s\n',i, dec2hex(subgraph.operators.operator(i).mutating_variable_inputs_pointer));  
    subgraph.operators.operator(i).intermediates_pointer = GetPointer(VT_OPERATOR.VT_INTERMEDIATES,subgraph.operators.operator(i).pointer, g_model, model_matrix_direction);
    fprintf('Intermediates pointer of operator %d is:  0x%s\n',i, dec2hex(subgraph.operators.operator(i).intermediates_pointer));  
end


%% Contents of the pointers above

for i=1:subgraph.operators.size
    subgraph.operators.operator(i).inputs = GetVector(subgraph.operators.operator(i).inputs_pointer,4,model_matrix_direction,g_model);
    subgraph.operators.operator(i).outputs = GetVector(subgraph.operators.operator(i).outputs_pointer,4,model_matrix_direction,g_model);
end


%% Name of the subgraph

subgraph.name.content = char(GetVector(subgraph.name.direction,1,model_matrix_direction,g_model));

%% Description of the model

description = char(GetVector(model.description,1,model_matrix_direction,g_model));

%% Metadata buffer of the model

metadata_buffer = GetVector(model.buffers,4,model_matrix_direction,g_model);

%% Buffers of the model

buffers.size = getnumber(g_model(model.buffers-model_matrix_direction+1),g_model(model.buffers-model_matrix_direction+2),g_model(model.buffers-model_matrix_direction+3),g_model(model.buffers-model_matrix_direction+4));

for i=1:buffers.size
    buffers.buffer(i).pointer= model.buffers + soffset_t_size*i + getnumber(g_model(model.buffers-model_matrix_direction+soffset_t_size*i+1),g_model(model.buffers-model_matrix_direction+soffset_t_size*i+2),g_model(model.buffers-model_matrix_direction+soffset_t_size*i+3),g_model(model.buffers-model_matrix_direction+soffset_t_size*i+4));
    fprintf('Buffer %d pointer: 0x%s\n',i, dec2hex(buffers.buffer(i).pointer));  
    buffers.buffer(i).data_pointer=GetPointer(VT_BUFFER.VT_DATA, buffers.buffer(i).pointer, g_model, model_matrix_direction);
    fprintf('Buffer %d data pointer:  0x%s\n',i, dec2hex(buffers.buffer(i).data_pointer));  
    buffers.buffer(i).data = GetVector(buffers.buffer(i).data_pointer,1,model_matrix_direction,g_model);
end

%% Metadata of the model

metadata.size = getnumber(g_model(model.metadata-model_matrix_direction+1),g_model(model.metadata-model_matrix_direction+2),g_model(model.metadata-model_matrix_direction+3),g_model(model.metadata-model_matrix_direction+4));

for i=1:metadata.size
    metadata.metadata(i).pointer= model.metadata + soffset_t_size*i + getnumber(g_model(model.metadata-model_matrix_direction+soffset_t_size*i+1),g_model(model.metadata-model_matrix_direction+soffset_t_size*i+2),g_model(model.metadata-model_matrix_direction+soffset_t_size*i+3),g_model(model.metadata-model_matrix_direction+soffset_t_size*i+4));
    fprintf('Metadata %d pointer: 0x%s\n',i, dec2hex(metadata.metadata(i).pointer));  
    metadata.metadata(i).name_pointer=GetPointer(VT_METADATA.VT_NAME, metadata.metadata(i).pointer, g_model, model_matrix_direction);
    fprintf('Metadata %d name pointer:  0x%s\n',i, dec2hex(metadata.metadata(i).name_pointer));  
    metadata.metadata(i).name = char(GetVector(metadata.metadata(i).name_pointer,1,model_matrix_direction,g_model));
    metadata.metadata(i).buffer = GetField(VT_METADATA.VT_BUFFER,metadata.metadata(i).pointer, g_model, model_matrix_direction,4,0);
    fprintf('Metadata %d buffer is:  %d\n',i, metadata.metadata(i).buffer);  
    
end

%% Getting back to the workflow

% Init function inside the micro_allocator

tail_ = allocatefromtail(tail_,sizeof_TFLiteTensor,alignof_TFLiteTensor);
 fprintf('tail_ pointer:  0x%s\n', dec2hex(tail_));  
for i=1:subgraph.tensors.size
    fprintf('Bucle de inicialización, tensor %d\r\n',i);
    if subgraph.tensors.tensor(i).quantization.scale ~= 0
%     InitializeRuntimeTensor(
%         memory_allocator_, *subgraph_->tensors()->Get(i), model_->buffers(),
%         error_reporter_, &context_->tensors[i]);
    tail_=allocatefromtail(tail_,sizeof_TfLiteAffineQuantization,alignof_TfLiteAffineQuantization);
    fprintf('tail_ pointer:  0x%s\n', dec2hex(tail_));
    tail_=allocatefromtail(tail_,sizeof_TFLiteIntArray+sizeof_TFLiteIntArray*length(subgraph.tensors.tensor(i).quantization.scale_content),alignof_TFLiteIntArray);
    fprintf('tail_ pointer:  0x%s\n', dec2hex(tail_)); 
    tail_=allocatefromtail(tail_,sizeof_TFLiteIntArray+sizeof_TFLiteIntArray*length(subgraph.tensors.tensor(i).quantization.scale_content),alignof_TFLiteIntArray);
    fprintf('tail_ pointer:  0x%s\n', dec2hex(tail_)); 

    end
end
