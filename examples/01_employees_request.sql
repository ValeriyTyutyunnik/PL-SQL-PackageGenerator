begin
  pkg_gen.init(p_table_name => 'employees',
               p_owner      => 'hr');

  pkg_gen.generate;

end;
/
