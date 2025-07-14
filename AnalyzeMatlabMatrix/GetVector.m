function data = GetVector(pointer, data_size, model_matrix_address,g_model)
  size_size = 4;

    vector_size=getnumber(g_model(pointer - model_matrix_address+1),g_model(pointer - model_matrix_address+2),g_model(pointer - model_matrix_address+3),g_model(pointer - model_matrix_address+4));

   
  data = zeros(1,vector_size);

  for i = 1:vector_size
      if(data_size==4)
        data(i)= getnumber(g_model(pointer - model_matrix_address+data_size*(i-1)+size_size+1),g_model(pointer - model_matrix_address+data_size*(i-1)+size_size+2),g_model(pointer - model_matrix_address+data_size*(i-1)+size_size+3),g_model(pointer - model_matrix_address+data_size*(i-1)+size_size+4));
      end
      if(data_size==1)
        data(i)= getnumber(g_model(pointer - model_matrix_address+data_size*(i-1)+size_size+1));
      end

end
