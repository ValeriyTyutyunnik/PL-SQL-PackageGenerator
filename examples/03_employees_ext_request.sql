begin
  pkg_gen.init(p_table_name => 'employees',
               p_owner      => 'hr',
               p_pkg_name   => 'employees_funcs');

  pkg_gen.use_type_attr := true;

  pkg_gen.pkg_doc := '/** TODO: add package documentation here' || chr(10)
              || ' * @created ' || to_char(sysdate, 'dd.mm.yyyy') || chr(10)
              || ' * @author {author}' || chr(10)
              || ' * @version 1.0' || chr(10)
              || ' */';

  pkg_gen.proc_doc := '  /** Procedure: {name}' || chr(10)
              || '   * Purpose: TODO add procedure documentation here' || chr(10)
              || '   * @author {author}' || chr(10)
              || '   * @created ' || to_char(sysdate, 'dd.mm.yyyy') || chr(10)
              || '   * @version 1.0' || chr(10)
              || '   * =========================================' || chr(10)
              || '{params}' || chr(10)
              || '   * @throws' || chr(10)
              || '   */';

  pkg_gen.func_doc := '  /** Function: {name}' || chr(10)
              || '   * Purpose: TODO add function documentation here' || chr(10)
              || '   * @author {author}' || chr(10)
              || '   * @created ' || to_char(sysdate, 'dd.mm.yyyy') || chr(10)
              || '   * @version 1.0' || chr(10)
              || '   * =========================================' || chr(10)
              || '{params}' || chr(10)
              || '   * @return' || chr(10)
              || '   * @throws' || chr(10)
              || '   */';

  pkg_gen.str_before_param_tag := '   * @param ';
  pkg_gen.str_after_param_tag := ' -';

  pkg_gen.doc_author := 'Batman';

  pkg_gen.add_exclude_update_col('first_name');
  pkg_gen.add_exclude_update_col('hire_date');
  pkg_gen.add_exclude_select_col('job_id');

  pkg_gen.generate;

end;
/
