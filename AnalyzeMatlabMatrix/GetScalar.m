function field = GetScalar(VT_OFFSET, data_, g_model, model_matrix_address, data_size, default_value)

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
        field = default_value;
    else    
        if data_size == 2 
            field = getnumber(g_model(data_-model_matrix_address+field_offset+1),g_model(data_-model_matrix_address+field_offset+2));
        else 
            if data_size == 1
            field = getnumber(g_model(data_-model_matrix_address+field_offset+1));
            end
            if data_size == 4
            field = getnumber(g_model(data_-model_matrix_address+field_offset+1),g_model(data_-model_matrix_address+field_offset+2),g_model(data_-model_matrix_address+field_offset+3),g_model(data_-model_matrix_address+field_offset+4));
            end
        end
    end

end
