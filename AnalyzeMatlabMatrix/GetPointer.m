function pointer = GetPointer(VT_OFFSET, data_, g_model, model_matrix_address)

    getnum=getnumber(g_model(data_ - model_matrix_address+1),g_model(data_ - model_matrix_address+2));
    getnum= double( typecast(uint16(getnum), 'int16') );
    vtable = data_ - getnum;
    %fprintf('Vtable address is 0x%s\n', dec2hex(vtable));
    vtsize = getnumber(g_model(vtable-model_matrix_address+1),g_model(vtable-model_matrix_address+2));
    % GetPointer
    field_offset = getnumber(g_model(vtable-model_matrix_address+VT_OFFSET+1),g_model(vtable-model_matrix_address+VT_OFFSET+2));
    
    
    if VT_OFFSET >= vtsize
        field_offset = 0;
    end

    if field_offset == 0 
        pointer = 0;
    else
        p = field_offset+data_;
        pointer = p + getnumber(g_model(p-model_matrix_address+1),g_model(p-model_matrix_address+2));
    end
  
end
