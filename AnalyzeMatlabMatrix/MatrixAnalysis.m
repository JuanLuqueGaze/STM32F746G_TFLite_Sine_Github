clear
run('MatrixData.m');
run('Globals.m')
tensor_arena = 0x200008C0;
tensor_arena_size= 4*1024;

tensor_head = tensor_arena;
tensor_tail = tensor_head + tensor_arena_size;

model_matrix_address = 0x10010000;
model_address = model_matrix_address + getnumber(g_model(1),g_model(2));
offsetmatrixmodel = getnumber(g_model(1),g_model(2));

fprintf('Model matrix address is 0x%s\n', dec2hex(model_matrix_address));
fprintf('Model address is 0x%s\n', dec2hex(model_address));
fprintf('Tensor head address is 0x%s\n', dec2hex(tensor_head));
fprintf('Tensor tail address is 0x%s\n', dec2hex(tensor_tail));

aligned_arena = tensor_head; % If it doesn't have any alignment problem
aligned_size = tensor_arena_size;

buffer_head = aligned_arena;
buffer_size = aligned_size;
buffer_tail = aligned_arena + aligned_size;
buffer_head_=buffer_head;
buffer_tail_=buffer_tail;
head_=buffer_head;
tail_=buffer_tail;

%%  Getting model parameters
       
        model.data_ = model_address;
        model.vtable = model.data_ - getnumber(g_model(model.data_ - model_matrix_address+1),g_model(model.data_ - model_matrix_address+2));
        model.version = GetScalar(VT_MODEL.VT_VERSION, model.data_, g_model, model_matrix_address,2,0);
        model.operator_codes = GetPointer(VT_MODEL.VT_OPERATOR_CODES, model_address, g_model, model_matrix_address);
        model.subgraphs = GetPointer(VT_MODEL.VT_SUBGRAPHS, model_address, g_model, model_matrix_address);
        model.description = GetPointer(VT_MODEL.VT_DESCRIPTION, model_address, g_model, model_matrix_address);
        model.buffers = GetPointer(VT_MODEL.VT_BUFFERS, model_address, g_model, model_matrix_address);
        model.metadata_buffer = GetPointer(VT_MODEL.VT_METADATA_BUFFER, model_address, g_model, model_matrix_address);
        model.metadata = GetPointer(VT_MODEL.VT_METADATA, model_address, g_model, model_matrix_address);

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

operator_codes.size = getnumber(g_model(model.operator_codes-model_matrix_address+1),g_model(model.operator_codes-model_matrix_address+2),g_model(model.operator_codes-model_matrix_address+3),g_model(model.operator_codes-model_matrix_address+4));

for i=1:operator_codes.size
    operator_codes.operator(i).pointer=model.operator_codes + soffset_t_size*i + getnumber(g_model(model.operator_codes-model_matrix_address+soffset_t_size*i+1),g_model(model.operator_codes-model_matrix_address+soffset_t_size*i+2),g_model(model.operator_codes-model_matrix_address+soffset_t_size*i+3),g_model(model.operator_codes-model_matrix_address+soffset_t_size*i+4));
    fprintf('Operator codes pointer 0x%s\n', dec2hex(operator_codes.operator(i).pointer));  
    operator_codes.operator(i).builtin_code=GetScalar(VT_OPERATORS.VT_BUILTIN_CODE, operator_codes.operator(i).pointer, g_model, model_matrix_address,1,0);
    operator_codes.operator(i).version=GetScalar(VT_OPERATORS.VT_VERSION, operator_codes.operator(i).pointer, g_model, model_matrix_address,2,1);
    operator_codes.operator(i).custom_code = GetPointer(VT_OPERATORS.VT_CUSTOM_CODE, operator_codes.operator(i).pointer, g_model, model_matrix_address);
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
pointer_to_subgraph = GetPointer(VT_MODEL.VT_SUBGRAPHS, model_address, g_model, model_matrix_address);
fprintf('Subgraph address is 0x%s\n', dec2hex(pointer_to_subgraph));

subgraph.size = getnumber(g_model(model.subgraphs-model_matrix_address+1),g_model(model.subgraphs-model_matrix_address+2),g_model(model.subgraphs-model_matrix_address+3),g_model(model.subgraphs-model_matrix_address+4));



%It only allows 1 subgraph
subgraph.address=model.subgraphs + soffset_t_size + getnumber(g_model(model.subgraphs-model_matrix_address+soffset_t_size+1),g_model(model.subgraphs-model_matrix_address+soffset_t_size+2),g_model(model.subgraphs-model_matrix_address+soffset_t_size+3),g_model(model.subgraphs-model_matrix_address+soffset_t_size+4));
subgraph.tensors.address = GetPointer(VT_SUBGRAPHS.VT_TENSORS, subgraph.address, g_model, model_matrix_address);
subgraph.inputs.address = GetPointer(VT_SUBGRAPHS.VT_INPUTS, subgraph.address, g_model, model_matrix_address);
subgraph.outputs.address = GetPointer(VT_SUBGRAPHS.VT_OUTPUTS, subgraph.address, g_model, model_matrix_address);
subgraph.operators.address = GetPointer(VT_SUBGRAPHS.VT_OPERATORS, subgraph.address, g_model, model_matrix_address);
subgraph.name.address = GetPointer(VT_SUBGRAPHS.VT_NAME, subgraph.address, g_model, model_matrix_address);

fprintf(['Subgraph analysis:\n' ...
        '  address: 0x%X\n' ...
        '  size: %d\n' ...
        '  tensors address: 0x%X\n' ...
        '  inputs address: 0x%X\n' ...
        '  outputs address: 0x%X\n' ...
        '  operators address: 0x%X\n' ...
        '  name address: 0x%X\n'], ...
        subgraph.address, ...
        subgraph.size, ...
        subgraph.tensors.address, ...
        subgraph.inputs.address, ...
        subgraph.outputs.address, ...
        subgraph.operators.address, ...
        subgraph.name.address);
        
%% Getting tensors inside of operator codes


subgraph.tensors.size = getnumber(g_model(subgraph.tensors.address-model_matrix_address+1),g_model(subgraph.tensors.address-model_matrix_address+2),g_model(subgraph.tensors.address-model_matrix_address+3),g_model(subgraph.tensors.address-model_matrix_address+4));


for i=1:subgraph.tensors.size
    subgraph.tensors.tensor(i).pointer=subgraph.tensors.address + soffset_t_size*i + getnumber(g_model(subgraph.tensors.address-model_matrix_address+soffset_t_size*i+1),g_model(subgraph.tensors.address-model_matrix_address+soffset_t_size*i+2),g_model(subgraph.tensors.address-model_matrix_address+soffset_t_size*i+3),g_model(subgraph.tensors.address-model_matrix_address+soffset_t_size*i+4));
    subgraph.tensors.tensor(i).shape_pointer = GetPointer(VT_TENSORS.VT_SHAPE,subgraph.tensors.tensor(i).pointer, g_model, model_matrix_address);
    fprintf('Tensor shape pointer of tensor %d is:  0x%s\n',i, dec2hex(subgraph.tensors.tensor(i).shape_pointer));  
    subgraph.tensors.tensor(i).type = GetScalar(VT_TENSORS.VT_TYPE,subgraph.tensors.tensor(i).pointer, g_model, model_matrix_address,1,0);
    fprintf('Tensor type of tensor %d is:  %d\n',i, subgraph.tensors.tensor(i).type);
    subgraph.tensors.tensor(i).buffer = GetScalar(VT_TENSORS.VT_BUFFER,subgraph.tensors.tensor(i).pointer, g_model, model_matrix_address,2,0);
    fprintf('Tensor buffer of tensor %d is:  %d\n',i, subgraph.tensors.tensor(i).buffer); 
    subgraph.tensors.tensor(i).name_pointer = GetPointer(VT_TENSORS.VT_NAME,subgraph.tensors.tensor(i).pointer, g_model, model_matrix_address);
    fprintf('Tensor name pointer of tensor %d is:  0x%s\n',i, dec2hex(subgraph.tensors.tensor(i).name_pointer));  
    subgraph.tensors.tensor(i).quantization_pointer = GetPointer(VT_TENSORS.VT_QUANTIZATION,subgraph.tensors.tensor(i).pointer, g_model, model_matrix_address);
    fprintf('Tensor quantization pointer of tensor %d is:  0x%s\n',i, dec2hex(subgraph.tensors.tensor(i).quantization_pointer));  
    subgraph.tensors.tensor(i).is_variable = GetScalar(VT_TENSORS.VT_IS_VARIABLE,subgraph.tensors.tensor(i).pointer, g_model, model_matrix_address,2,0);
    fprintf('Tensor is_variable of tensor %d is:  %d\n',i, subgraph.tensors.tensor(i).is_variable); 
    subgraph.tensors.tensor(i).sparsity_pointer = GetPointer(VT_TENSORS.VT_SPARSITY,subgraph.tensors.tensor(i).pointer, g_model, model_matrix_address);
    fprintf('Tensor sparsity pointer of tensor %d is:  0x%s\n',i, dec2hex(subgraph.tensors.tensor(i).sparsity_pointer));  
    subgraph.tensors.tensor(i).shape_signature_pointer = GetPointer(VT_TENSORS.VT_SHAPE_SIGNATURE,subgraph.tensors.tensor(i).pointer, g_model, model_matrix_address);
    fprintf('Tensor shape signature pointer of tensor %d is:  0x%s\n',i, dec2hex(subgraph.tensors.tensor(i).shape_signature_pointer));  
    fprintf('\n');  

end

%% Getting inside of the tensor shape 
for i=1:subgraph.tensors.size
    subgraph.tensors.tensor(i).shape = GetVector(subgraph.tensors.tensor(i).shape_pointer,4,model_matrix_address,g_model);
end

%% Getting inside of the tensor name
for i=1:subgraph.tensors.size
    subgraph.tensors.tensor(i).name = char(GetVector(subgraph.tensors.tensor(i).name_pointer,1,model_matrix_address,g_model));
end

%% Getting inside of the tensor quantization parameters

for i=1:subgraph.tensors.size

        subgraph.tensors.tensor(i).quantization.min = GetPointer(VT_QUANTIZATION.VT_MIN,subgraph.tensors.tensor(i).quantization_pointer, g_model, model_matrix_address);
    fprintf('Tensor min pointer of tensor %d is:  0x%s\n',i, dec2hex( subgraph.tensors.tensor(i).quantization.min));  
        subgraph.tensors.tensor(i).quantization.max = GetPointer(VT_QUANTIZATION.VT_MAX,subgraph.tensors.tensor(i).quantization_pointer, g_model, model_matrix_address);
    fprintf('Tensor max pointer of tensor %d is:  0x%s\n',i, dec2hex( subgraph.tensors.tensor(i).quantization.max));  
    subgraph.tensors.tensor(i).quantization.scale = GetPointer(VT_QUANTIZATION.VT_SCALE,subgraph.tensors.tensor(i).quantization_pointer, g_model, model_matrix_address);
    fprintf('Tensor scale pointer of tensor %d is:  0x%s\n',i, dec2hex( subgraph.tensors.tensor(i).quantization.scale));
        subgraph.tensors.tensor(i).quantization.zero_point = GetPointer(VT_QUANTIZATION.VT_ZERO_POINT,subgraph.tensors.tensor(i).quantization_pointer, g_model, model_matrix_address);
    fprintf('Tensor zero point pointer of tensor %d is:  0x%s\n',i, dec2hex( subgraph.tensors.tensor(i).quantization.zero_point));  
        subgraph.tensors.tensor(i).quantization.details = GetPointer(VT_QUANTIZATION.VT_DETAILS,subgraph.tensors.tensor(i).quantization_pointer, g_model, model_matrix_address);
    fprintf('Tensor details pointer of tensor %d is:  0x%s\n',i, dec2hex( subgraph.tensors.tensor(i).quantization.details));  
             subgraph.tensors.tensor(i).quantization.details_type = GetScalar(VT_QUANTIZATION.VT_DETAILS_TYPE,subgraph.tensors.tensor(i).quantization_pointer, g_model, model_matrix_address,1,0);
    fprintf('Tensor details type of tensor %d is:  %d\n',i, subgraph.tensors.tensor(i).quantization.details_type);
              subgraph.tensors.tensor(i).quantization.quantized_dimension = GetScalar(VT_QUANTIZATION.VT_QUANTIZED_DIMENSION,subgraph.tensors.tensor(i).quantization_pointer, g_model, model_matrix_address,4,0);
    fprintf('Tensor quantized dimension of tensor %d is:  %d\n',i, subgraph.tensors.tensor(i).quantization.quantized_dimension);
  
end

for i = 1:subgraph.tensors.size

   subgraph.tensors.tensor(i).quantization.scale_content = GetVector(subgraph.tensors.tensor(i).quantization.scale,4,model_matrix_address,g_model);
   subgraph.tensors.tensor(i).quantization.zero_point_content = GetVector(subgraph.tensors.tensor(i).quantization.scale,8,model_matrix_address,g_model);

end

%% Getting input and output

for i=1:subgraph.size
    subgraph.inputs.content = GetVector(subgraph.inputs.address,4,model_matrix_address,g_model);
    subgraph.outputs.content = GetVector(subgraph.outputs.address,4,model_matrix_address,g_model);
end

%% Getting subgraph operator

subgraph.operators.size = getnumber(g_model(subgraph.operators.address-model_matrix_address+1),g_model(subgraph.operators.address-model_matrix_address+2),g_model(subgraph.operators.address-model_matrix_address+3),g_model(subgraph.operators.address-model_matrix_address+4));

for i=1:subgraph.operators.size
    subgraph.operators.operator(i).pointer= subgraph.operators.address + soffset_t_size*i + getnumber(g_model(subgraph.operators.address-model_matrix_address+soffset_t_size*i+1),g_model(subgraph.operators.address-model_matrix_address+soffset_t_size*i+2),g_model(subgraph.operators.address-model_matrix_address+soffset_t_size*i+3),g_model(subgraph.operators.address-model_matrix_address+soffset_t_size*i+4));
    fprintf('Operator codes pointer 0x%s\n', dec2hex(subgraph.operators.operator(i).pointer));  
    subgraph.operators.operator(i).op_code_index=GetScalar(VT_OPERATOR.VT_OPCODE_INDEX, subgraph.operators.operator(i).pointer, g_model, model_matrix_address,4,0);
    fprintf('Op code index of operator %d is:  %d\n',i, subgraph.operators.operator(i).op_code_index);
    subgraph.operators.operator(i).inputs_pointer = GetPointer(VT_OPERATOR.VT_INPUTS,subgraph.operators.operator(i).pointer, g_model, model_matrix_address);
    fprintf('Input pointer of operator %d is:  0x%s\n',i, dec2hex(subgraph.operators.operator(i).inputs_pointer));  
    subgraph.operators.operator(i).outputs_pointer = GetPointer(VT_OPERATOR.VT_OUTPUTS,subgraph.operators.operator(i).pointer, g_model, model_matrix_address);
    fprintf('Output pointer of operator %d is:  0x%s\n',i, dec2hex(subgraph.operators.operator(i).outputs_pointer));  
    subgraph.operators.operator(i).builtin_options_type = GetScalar(VT_OPERATOR.VT_BUILTIN_OPTIONS_TYPE,subgraph.operators.operator(i).pointer, g_model, model_matrix_address,1,0);
    fprintf('Builtin type of operator %d is:  %d\n',i, subgraph.operators.operator(i).builtin_options_type);  
    subgraph.operators.operator(i).builtin_options_pointer = GetPointer(VT_OPERATOR.VT_BUILTIN_OPTIONS,subgraph.operators.operator(i).pointer, g_model, model_matrix_address);
    fprintf('Builtin options pointer of operator %d is:  0x%s\n',i, dec2hex(subgraph.operators.operator(i).builtin_options_pointer));  
    subgraph.operators.operator(i).custom_options_pointer = GetPointer(VT_OPERATOR.VT_CUSTOM_OPTIONS,subgraph.operators.operator(i).pointer, g_model, model_matrix_address);
    fprintf('Custom options pointer of operator %d is:  0x%s\n',i, dec2hex(subgraph.operators.operator(i).custom_options_pointer));  
    subgraph.operators.operator(i).custom_options_format = GetScalar(VT_OPERATOR.VT_CUSTOM_OPTIONS_FORMAT,subgraph.operators.operator(i).pointer, g_model, model_matrix_address,1,0);
    fprintf('Custom options format of operator %d is:  %d\n',i, subgraph.operators.operator(i).custom_options_format);  
    subgraph.operators.operator(i).mutating_variable_inputs_pointer = GetPointer(VT_OPERATOR.VT_MUTATING_VARIABLE_INPUTS,subgraph.operators.operator(i).pointer, g_model, model_matrix_address);
    fprintf('Mutating variable inputs pointer of operator %d is:  0x%s\n',i, dec2hex(subgraph.operators.operator(i).mutating_variable_inputs_pointer));  
    subgraph.operators.operator(i).intermediates_pointer = GetPointer(VT_OPERATOR.VT_INTERMEDIATES,subgraph.operators.operator(i).pointer, g_model, model_matrix_address);
    fprintf('Intermediates pointer of operator %d is:  0x%s\n',i, dec2hex(subgraph.operators.operator(i).intermediates_pointer));  
end

%% Contents of the pointers above

for i=1:subgraph.operators.size
    subgraph.operators.operator(i).inputs = GetVector(subgraph.operators.operator(i).inputs_pointer,4,model_matrix_address,g_model);
    subgraph.operators.operator(i).outputs = GetVector(subgraph.operators.operator(i).outputs_pointer,4,model_matrix_address,g_model);
end

%% Name of the subgraph

subgraph.name.content = char(GetVector(subgraph.name.address,1,model_matrix_address,g_model));

%% Description of the model

description = char(GetVector(model.description,1,model_matrix_address,g_model));

%% Metadata buffer of the model

metadata_buffer = GetVector(model.buffers,4,model_matrix_address,g_model);

%% Buffers of the model

buffers.size = getnumber(g_model(model.buffers-model_matrix_address+1),g_model(model.buffers-model_matrix_address+2),g_model(model.buffers-model_matrix_address+3),g_model(model.buffers-model_matrix_address+4));

for i=1:buffers.size
    buffers.buffer(i).pointer= model.buffers + soffset_t_size*i + getnumber(g_model(model.buffers-model_matrix_address+soffset_t_size*i+1),g_model(model.buffers-model_matrix_address+soffset_t_size*i+2),g_model(model.buffers-model_matrix_address+soffset_t_size*i+3),g_model(model.buffers-model_matrix_address+soffset_t_size*i+4));
    fprintf('Buffer %d pointer: 0x%s\n',i, dec2hex(buffers.buffer(i).pointer));  
    buffers.buffer(i).data_pointer=GetPointer(VT_BUFFER.VT_DATA, buffers.buffer(i).pointer, g_model, model_matrix_address);
    fprintf('Buffer %d data pointer:  0x%s\n',i, dec2hex(buffers.buffer(i).data_pointer));  
    buffers.buffer(i).data = GetVector(buffers.buffer(i).data_pointer,1,model_matrix_address,g_model);
end

%% Metadata of the model

metadata.size = getnumber(g_model(model.metadata-model_matrix_address+1),g_model(model.metadata-model_matrix_address+2),g_model(model.metadata-model_matrix_address+3),g_model(model.metadata-model_matrix_address+4));

for i=1:metadata.size
    metadata.metadata(i).pointer= model.metadata + soffset_t_size*i + getnumber(g_model(model.metadata-model_matrix_address+soffset_t_size*i+1),g_model(model.metadata-model_matrix_address+soffset_t_size*i+2),g_model(model.metadata-model_matrix_address+soffset_t_size*i+3),g_model(model.metadata-model_matrix_address+soffset_t_size*i+4));
    fprintf('Metadata %d pointer: 0x%s\n',i, dec2hex(metadata.metadata(i).pointer));  
    metadata.metadata(i).name_pointer=GetPointer(VT_METADATA.VT_NAME, metadata.metadata(i).pointer, g_model, model_matrix_address);
    fprintf('Metadata %d name pointer:  0x%s\n',i, dec2hex(metadata.metadata(i).name_pointer));  
    metadata.metadata(i).name = char(GetVector(metadata.metadata(i).name_pointer,1,model_matrix_address,g_model));
    metadata.metadata(i).buffer = GetScalar(VT_METADATA.VT_BUFFER,metadata.metadata(i).pointer, g_model, model_matrix_address,4,0);
    fprintf('Metadata %d buffer is:  %d\n',i, metadata.metadata(i).buffer);  
end

%% Getting back to the workflow

% Init function inside the micro_allocator

% tail_ = allocatefromtail(tail_,sizeof_TFLiteTensor,alignof_TFLiteTensor);
%  fprintf('tail_ pointer:  0x%s\n', dec2hex(tail_));  
% for i=1:subgraph.tensors.size
%     fprintf('Bucle de inicialización, tensor %d\r\n',i);
%     if subgraph.tensors.tensor(i).quantization.scale ~= 0
% %     InitializeRuntimeTensor(
% %         memory_allocator_, *subgraph_->tensors()->Get(i), model_->buffers(),
% %         error_reporter_, &context_->tensors[i]);
%     tail_=allocatefromtail(tail_,sizeof_TfLiteAffineQuantization,alignof_TfLiteAffineQuantization);
%     fprintf('tail_ pointer:  0x%s\n', dec2hex(tail_));
%     tail_=allocatefromtail(tail_,sizeof_TFLiteIntArray+sizeof_TFLiteIntArray*length(subgraph.tensors.tensor(i).quantization.scale_content),alignof_TFLiteIntArray);
%     fprintf('tail_ pointer:  0x%s\n', dec2hex(tail_)); 
%     tail_=allocatefromtail(tail_,sizeof_TFLiteIntArray+sizeof_TFLiteIntArray*length(subgraph.tensors.tensor(i).quantization.scale_content),alignof_TFLiteIntArray);
%     fprintf('tail_ pointer:  0x%s\n', dec2hex(tail_)); 
%     end
% end
