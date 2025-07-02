function pointer = GetPointer(VT_OFFSET, data_, offsetmatrixmodel, g_model, model_matrix_direction)

  
    vtable = data_ - getnumber(g_model(offsetmatrixmodel+1),g_model(offsetmatrixmodel+2));
    fprintf('Vtable direction is 0x%s\n', dec2hex(vtable));
    vtsize = getnumber(g_model(vtable-model_matrix_direction+1),g_model(vtable-model_matrix_direction+2));
    % GetPointer
    field_offset = getnumber(g_model(vtable-model_matrix_direction+VT_OFFSET+1),g_model(vtable-model_matrix_direction+VT_OFFSET+2));
    p = field_offset+data_;
    pointer = p + getnumber(g_model(p-model_matrix_direction+1),g_model(p-model_matrix_direction+2));


end
