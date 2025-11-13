      program  fabm_test

      use fabm
      
      class (type_fabm_model), pointer :: model

      model => fabm_create_model()

      end program
