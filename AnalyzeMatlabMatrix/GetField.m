function field = GetField(VT_OFFSET, data_, g_model, model_matrix_direction, data_size, default_value)

    getnum=getnumber(g_model(data_ - model_matrix_direction+1),g_model(data_ - model_matrix_direction+2));
    getnum= double( typecast(uint16(getnum), 'int16') );
    vtable = data_ - getnum;
    %fprintf('Vtable direction is 0x%s\n', dec2hex(vtable));
    vtsize = getnumber(g_model(vtable-model_matrix_direction+1),g_model(vtable-model_matrix_direction+2));
    % GetPointer
    field_offset = getnumber(g_model(vtable-model_matrix_direction+VT_OFFSET+1),g_model(vtable-model_matrix_direction+VT_OFFSET+2));
    
    if VT_OFFSET >= vtsize
        field_offset = 0;
    end


    if field_offset == 0
        field = default_value;
    else    
        if data_size == 2 
            field = getnumber(g_model(data_-model_matrix_direction+field_offset+1),g_model(data_-model_matrix_direction+field_offset+2));
        else 
            if data_size == 1
            field = getnumber(g_model(data_-model_matrix_direction+field_offset+1));
            end
        end
    end

end
