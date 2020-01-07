-- encoding Windows-1251
-- https://github.com/ValeriyTyutyunnik/PL-SQL-PackageGenerator

declare
  /*
    MIT License

    Copyright (c) 2020 Valeriy Tyutyunnik

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
  */

  /*********************************************
  *************  pkg_gen settings  *************
  **********************************************/

  -- define the prefix and suffix that should be part of the parameter/variable name
  param_prefix  varchar2(5 char) := 'p_';
  param_suffix  varchar2(5 char);
  var_prefix    varchar2(5 char) := 'l_';
  var_suffix    varchar2(5 char);

  -- if true returns null when no_data_found exception raises at select functions otherwise raises an application error
  use_ndf_ret_null boolean := true;

  -- if true uses %type attribute for variable and parameter declarations
  use_type_attr boolean := false;

  -- set false for any program types whose code should not be generated
  print_ins_proc        boolean := true;
  print_ins_func        boolean := true;
  print_del_proc        boolean := true;
  print_common_upd_proc boolean := true;
  print_upd_proc        boolean := true;
  print_exist_func      boolean := true;
  print_select_funcs    boolean := true;

  type varchar_tbl is table of varchar2(200);

  -- add lowercase column name to this collections for not generate update/select functions
  -- you can fill this tables with add_exclude_select_col, add_exclude_update_col procedures
  -- this collections will reset whenever procedure "init" executed
  g_select_excluded_cols varchar_tbl := varchar_tbl();
  g_update_excluded_cols varchar_tbl := varchar_tbl();


  /**********************************************
   **********  documentation templates  *********
   **********************************************/

  /**
   * Set documentation format you need or leave it empty to leave code without documentation.
   * Availablable documentation snippets:
   *   {author} - substitutes the value of a variable doc_author
   *   {name}   - programm name
   *   {params} - all programm parameters line by line with str_before_param_tag data at begin of line
   */

  pkg_doc              varchar2(1000 char);
  proc_doc             varchar2(1000 char);
  func_doc             varchar2(1000 char);
  str_before_param_tag varchar2(10 char);
  doc_author           varchar2(100 char);


  /**********************************************
   *********  local types and variables  ********
   **********************************************/

  lf  constant varchar2(1 char) := chr(10);
  lf2 constant varchar2(2 char) := lf || lf;

  type col_rec is record (column_name     varchar2(128),
                          data_type       varchar2(128),
                          data_precision  number,
                          data_scale      number,
                          char_length     number,
                          char_used       varchar2(1),
                          virtual_column  varchar2(3),
                          nullable        varchar2(1));

  type cols_tbl is table of col_rec index by pls_integer;

  type params_tbl is table of varchar2(200) index by pls_integer;

  g_table_name    varchar2(128);
  g_alias         varchar2(1);
  g_pk_column_rec col_rec;
  g_columns_tbl   cols_tbl;
  g_pkg_name      varchar2(128);
  g_chr_limit     integer := 30;
  g_initialized   boolean := false;


  /**********************************************
   **************  local programs  **************
   **********************************************/

  /**
   * return declaration data type for variable/parameter by system information
   * @param p_data_type      - datatype of the column
   * @param p_data_precision - decimal precision for number and float datatypes
   * @param p_data_scale     - digits to the right of the decimal point in a number
   * @param p_char_length    - length of the column for char datatypes
   * @param p_char_used      - indicates that the column uses BYTE length semantics (B) or CHAR length semantics (C)
                               (for char datatypes)
   * @param p_add_precision  - if false then returns only data type name without precision or length
   */
  function get_data_type(p_data_type      varchar2,
                         p_data_precision number,
                         p_data_scale     number,
                         p_char_length    number    default null,
                         p_char_used      varchar2  default null,
                         p_add_precision  boolean   default true)
  return varchar2
  is
    l_result varchar2(100);
  begin
    if p_data_type = 'NUMBER' and p_data_precision is null and p_data_scale = 0 then
      l_result := 'integer';
    else
      l_result := p_data_type;
      if p_add_precision then
        if p_data_precision is not null and p_data_scale is not null then
          l_result := l_result || '(' || p_data_precision || ', ' || p_data_scale || ')';
        elsif nvl(p_char_length, 0) > 0 then
          l_result := l_result || '(' || p_char_length;
          if p_char_used = 'C' then
            l_result := l_result || ' char';
          end if;
          l_result := l_result || ')';
        end if;
      end if;
    end if;

    return l_result;

  end get_data_type;

  /**
   * return declaration type for parameter depending on the use_type_attr setting
   * @param p_column_name - name of the column
   * @param p_data_type   - column data_type
   */
  function get_declaration_type(p_column_name varchar2,
                                p_data_type   varchar2)
  return varchar2
  is
    l_result varchar2(200);
  begin
    if use_type_attr then
      l_result := g_table_name || '.' || p_column_name || '%type';
    else
      l_result := p_data_type;
    end if;

    return l_result;

  end get_declaration_type;

  /**
   * replaces snippets at documentation template
   * @param p_doc  - documetation template
   * @param p_name - name of the documented object
   */
  function format_doc(p_doc    varchar2,
                      p_name   varchar2)
  return varchar2
  is
    l_result varchar2(10000);
  begin
    if p_doc is not null then
      l_result := replace(p_doc, '{author}', doc_author);
      l_result := replace(l_result, '{name}', p_name);
    end if;

    return l_result;

  exception
    when others then
      raise_application_error(-20001, dbms_utility.format_error_stack);
  end format_doc;

  /**
   * replaces snippets at documentation template
   * @override
   * @param p_doc  - documetation template
   * @param p_name - name of the documented object
   * @param p_params - list of params than should replace {params} snippets
   */
  function format_doc(p_doc    varchar2,
                      p_name   varchar2,
                      p_params params_tbl)
  return varchar2
  is
    l_result varchar2(10000);
    l_tmp    varchar2(4000);
  begin
    if p_doc is not null then
      l_result := format_doc(p_doc, p_name);

      if instr(l_result, '{params}') > 0 then
        for i in 1 .. p_params.count loop
          if i > 1 then
            l_tmp := l_tmp || lf;
          end if;
          l_tmp := l_tmp || str_before_param_tag || p_params(i);
        end loop;
        l_result := replace(l_result, '{params}', l_tmp);
      end if;
    end if;

    return l_result;
  exception
    when others then
      raise_application_error(-20001, dbms_utility.format_error_stack);
  end format_doc;

  /**
   * Return the param name that should be used in code.
   * Name consists of prefix, middle part and suffix.
   * Prefix and suffix is set by param_prefix and param_suffix variables and could be null.
   * Parameter length is limited by setting in procedure init.name_chr_limit
   * @param p_param_middle_part - main part of parameter name
   */
  function get_param_name(p_param_middle_part varchar2)
  return varchar2
  is
  begin
    return lower(substr(param_prefix || p_param_middle_part || param_suffix, 1, g_chr_limit));
  end get_param_name;

  /**
   * Return the param name that should be used in code.
   * Name consists of prefix, middle part and suffix.
   * Prefix and suffix is set by var_prefix and var_suffix variables and could be null.
   * Parameter length is limited by setting in procedure init.name_chr_limit
   * @param p_var_middle_part - main part of variable name
   */
  function get_var_name(p_var_middle_part varchar2)
  return varchar2
  is
  begin
    return lower(substr(var_prefix || p_var_middle_part || var_suffix, 1, g_chr_limit));
  end get_var_name;


  /**********************************************
   **************  global programs  *************
   **********************************************/

  /**
   * add column to the exclusion list to prevent
   * the generation of a select function code
   * @param p_col_name - column name
   */
  procedure add_exclude_select_col(p_col_name varchar2)
  is
  begin
    if p_col_name is not null and not lower(p_col_name) member of g_select_excluded_cols then
      g_select_excluded_cols.extend;
      g_select_excluded_cols(g_select_excluded_cols.last) := lower(p_col_name);
    end if;
  end add_exclude_select_col;

  /**
   * add column to the exclusion list to prevent
   * the generation of a update procedure code
   * @param p_col_name - column name
   */
  procedure add_exclude_update_col(p_col_name varchar2)
  is
  begin
    if p_col_name is not null and not lower(p_col_name) member of g_update_excluded_cols then
      g_update_excluded_cols.extend;
      g_update_excluded_cols(g_update_excluded_cols.last) := lower(p_col_name);
    end if;
  end add_exclude_update_col;

  /**
   * The main procedure in which the internal data is initialized and some settings are reset.
   * The procedure must be called first.
   * @param p_table_name     - Name of the table with which the generated code will work.
   *                           The table must be physically created.
   * @param p_owner          - table owner (schema)
   * @param p_pk_column      - Primary key of the table. if not specified, then the data will be taken
   *                           from the system information about the primary key of the table.
   *                           If physically the primary key does not exist,
   *                           be sure to indicate in this parameter the column that acts as the primary key.
   *                           In other cases, code generation does not work.
   * @param p_pkg_name       - The name of the package that will be installed for the generated code.
   *                           If not specified then "%table_name%_pkg" will be used.
   * @param p_name_chr_limit - Number of characters that limits the length of the variable/parameter name.
   *                           Default 30. From version 12.2 of Oracle Database, the maximum size of
   *                           most identifiers has been increased from 30 to 128 bytes.
   *                           Minimum size is 10.
   */
  procedure init(p_table_name     varchar2,
                 p_owner          varchar2 default null,
                 p_pk_column      varchar2 default null,
                 p_pkg_name       varchar2 default null,
                 p_name_chr_limit integer  default null)
  is
    l_table_name varchar2(128);
    l_owner      varchar2(128);
  begin
    g_initialized := false;
    g_chr_limit := 30;
    if p_table_name is null then
      raise_application_error(-20001, 'empty table name!');
    end if;

    l_owner := coalesce(upper(p_owner), user);
    l_table_name := upper(p_table_name);
    g_table_name := lower(p_table_name);
    g_alias := substr(g_table_name, 1, 1);
    g_select_excluded_cols := varchar_tbl();
    g_update_excluded_cols := varchar_tbl();

    if p_name_chr_limit is not null then
      if p_name_chr_limit between 10 and 128 then
        g_chr_limit := p_name_chr_limit;
      else
        raise_application_error(-20002, 'chr_limit must be between 10 and 128');
      end if;
    end if;

    if p_pkg_name is not null then
      if length(p_pkg_name) <= 128 then
        g_pkg_name := lower(p_pkg_name);
      else
        raise_application_error(-20003, 'p_pkg_name is too long');
      end if;
    else
      g_pkg_name := substr(g_table_name, 1, g_chr_limit);
      if length(g_pkg_name) + 4 <= g_chr_limit then
        g_pkg_name := g_pkg_name||'_pkg';
      end if;
    end if;

    begin
      if p_pk_column is null then
        select lower(tc.column_name),
               lower(tc.data_type),
               tc.data_precision,
               tc.data_scale,
               tc.char_length,
               tc.char_used,
               tc.virtual_column,
               tc.nullable
          into g_pk_column_rec
          from all_constraints c,
               all_cons_columns cc,
               all_tab_cols tc
         where c.owner = l_owner
           and c.table_name = l_table_name
           and c.constraint_type = 'P'
           and c.constraint_name = cc.constraint_name
           and c.owner = cc.owner
           and c.table_name = cc.table_name
           and cc.column_name = tc.column_name
           and cc.owner = tc.owner
           and cc.table_name = tc.table_name;
      else
        select lower(tc.column_name),
               lower(tc.data_type),
               tc.data_precision,
               tc.data_scale,
               tc.char_length,
               tc.char_used,
               tc.virtual_column,
               tc.nullable
          into g_pk_column_rec
          from all_tab_cols tc
         where tc.column_name = upper(p_pk_column)
           and tc.owner = l_owner
           and tc.table_name = l_table_name;
      end if;
    exception
      when no_data_found then
        raise_application_error(-20004, 'Primary key column not found or table not exists!');
    end;

    for rec in (select lower(tc.column_name) as column_name,
                       lower(tc.data_type) as data_type,
                       tc.data_precision,
                       tc.data_scale,
                       tc.char_length,
                       tc.char_used,
                       tc.virtual_column,
                       tc.nullable
                  from all_tab_cols tc
                 where tc.owner = l_owner
                   and tc.table_name = l_table_name
                   and lower(tc.column_name) != g_pk_column_rec.column_name
                   and tc.hidden_column = 'NO'
                order by tc.column_id)
    loop
      g_columns_tbl(g_columns_tbl.count+1).column_name := rec.column_name;
      g_columns_tbl(g_columns_tbl.count).data_type := rec.data_type;
      g_columns_tbl(g_columns_tbl.count).data_precision := rec.data_precision;
      g_columns_tbl(g_columns_tbl.count).data_scale := rec.data_scale;
      g_columns_tbl(g_columns_tbl.count).char_length := rec.char_length;
      g_columns_tbl(g_columns_tbl.count).char_used := rec.char_used;
      g_columns_tbl(g_columns_tbl.count).virtual_column := rec.virtual_column;
      g_columns_tbl(g_columns_tbl.count).nullable := rec.nullable;
    end loop;

    g_initialized := true;

  exception
    when others then
      raise_application_error(-20000, dbms_utility.format_error_stack);
  end init;

  /**
   * Generates a procedure that inserts data into a table.
   * As parameters, all columns of the table are used except virtual ones.
   * For nullable columns, the parameters are set to the default null
   * @param p_spec - generated code for package spec
   * @param p_body - generated code for package body
   */
  procedure gen_ins_proc(p_spec out varchar2,
                         p_body out varchar2)
  is
    l_params_tab    params_tbl;
    l_name          varchar2(128);
    l_line_len      number;
    l_first_col_set boolean := false;
  begin
    if not g_initialized then
      raise_application_error(-20001, 'Not initialized');
    end if;

    l_name := 'ins_'||substr(g_table_name, 1, g_chr_limit-4);
    p_body := '  procedure ' || l_name || '(';
    l_line_len := length(p_body);

    if g_pk_column_rec.virtual_column <> 'YES' then
      l_params_tab(l_params_tab.count+1) := get_param_name(g_pk_column_rec.column_name);
      p_body := p_body || l_params_tab(l_params_tab.count) || ' '
                       || get_declaration_type(g_pk_column_rec.column_name, g_pk_column_rec.data_type);
      l_first_col_set := true;
    end if;

    for i in 1 .. g_columns_tbl.count loop
      continue when g_columns_tbl(i).virtual_column = 'YES';
      l_params_tab(l_params_tab.count+1) := get_param_name(g_columns_tbl(i).column_name);
      if l_first_col_set then
        p_body := p_body || ',' || lf || rpad(' ', l_line_len);
      end if;
      p_body := p_body || l_params_tab(l_params_tab.count) || ' '
                       || get_declaration_type(g_columns_tbl(i).column_name, g_columns_tbl(i).data_type)
                       || case
                            when g_columns_tbl(i).nullable = 'Y'
                              then ' default null'
                            else null
                          end;
      l_first_col_set := true;
    end loop;

    if l_params_tab.count = 0 then
      p_body := null;
      p_spec := null;
      return;
    end if;

    p_body := p_body || ')';
    p_spec := p_body || ';' || lf2;

    p_body := p_body || lf || '  is' || lf || '  begin' || lf2
                     || '    insert' || lf
                     || '      into ' || g_table_name || ' (';

    l_line_len := 13 + length(g_table_name);
    l_first_col_set := false;

    if g_pk_column_rec.virtual_column <> 'YES' then
      p_body := p_body || g_pk_column_rec.column_name;
      l_first_col_set := true;
    end if;

    for i in 1 .. g_columns_tbl.count loop
      continue when g_columns_tbl(i).virtual_column = 'YES';
      if l_first_col_set then
        p_body := p_body || ',' || lf || rpad(' ', l_line_len);
      end if;
      p_body := p_body || g_columns_tbl(i).column_name;
      l_first_col_set := true;
    end loop;

    p_body := p_body || ')' || lf || '      values (';
    l_line_len := 14;

    for i in 1 .. l_params_tab.count loop
      if i > 1 then
        p_body := p_body || ',' || lf || rpad(' ', l_line_len);
      end if;
      p_body := p_body || l_params_tab(i);
    end loop;

    p_body := p_body || ');' || lf2
                     || '  exception' || lf
                     || '    when others then' || lf
                     || '      raise_application_error(-20001, dbms_utility.format_error_stack);' || lf
                     || '  end ' || l_name || ';' || lf2;

    p_body := lower(p_body);
    p_spec := lower(p_spec);

    if proc_doc is not null then
      p_body := format_doc(proc_doc, l_name, l_params_tab) || lf || p_body;
      p_spec := format_doc(proc_doc, l_name, l_params_tab) || lf || p_spec;
    end if;

  exception
    when others then
      raise_application_error(-20000, dbms_utility.format_error_stack);
  end gen_ins_proc;

  /**
   * Generates a function that inserts data into a table and returns PK value of created row.
   * As parameters, all columns of the table are used except virtual ones.
   * For nullable columns, the parameters are set to the default null
   * @param p_spec - generated code for package spec
   * @param p_body - generated code for package body
   */
  procedure gen_ins_func(p_spec out varchar2,
                         p_body out varchar2)
  is
    l_params_tab    params_tbl;
    l_name          varchar2(128);
    l_res_var_name  varchar2(128) := get_var_name('result');
    l_line_len      number;
    l_first_col_set boolean := false;
  begin
    if not g_initialized then
      raise_application_error(-20001, 'Not initialized');
    end if;

    l_name := 'ins_'||substr(g_table_name, 1, g_chr_limit-4);
    p_body := '  function ' || l_name || '(';
    l_line_len := length(p_body);

    if g_pk_column_rec.virtual_column <> 'YES' then
      l_params_tab(l_params_tab.count+1) := get_param_name(g_pk_column_rec.column_name);
      p_body := p_body || l_params_tab(l_params_tab.count) || ' '
                       || get_declaration_type(g_pk_column_rec.column_name, g_pk_column_rec.data_type);
      l_first_col_set := true;
    end if;

    for i in 1 .. g_columns_tbl.count loop
      continue when g_columns_tbl(i).virtual_column = 'YES';
      if l_first_col_set then
        p_body := p_body || ',' || lf || rpad(' ', l_line_len);
      end if;
      l_params_tab(l_params_tab.count+1) := get_param_name(g_columns_tbl(i).column_name);
      p_body := p_body || l_params_tab(l_params_tab.count) || ' '
                       || get_declaration_type(g_columns_tbl(i).column_name, g_columns_tbl(i).data_type)
                       || case
                            when g_columns_tbl(i).nullable = 'Y'
                              then ' default null'
                            else null
                          end;
      l_first_col_set := true;
    end loop;

    if l_params_tab.count = 0 then
      p_body := null;
      p_spec := null;
      return;
    end if;

    p_body := p_body || ')' || lf || '  return '
                     || get_declaration_type(g_pk_column_rec.column_name,
                                             get_data_type(g_pk_column_rec.data_type,
                                                           g_pk_column_rec.data_precision,
                                                           g_pk_column_rec.data_scale,
                                                           p_add_precision => false));

    p_spec := p_body || ';' || lf2;

    p_body := p_body || lf || '  is' || lf || '    ' || l_res_var_name || ' '
                     || get_declaration_type(g_pk_column_rec.column_name,
                                             get_data_type(g_pk_column_rec.data_type,
                                                           g_pk_column_rec.data_precision,
                                                           g_pk_column_rec.data_scale,
                                                           g_pk_column_rec.char_length,
                                                           g_pk_column_rec.char_used))
                     || ';' || lf || '  begin' || lf2
                     || '    insert ' || lf
                     || '      into ' || g_table_name || ' (';

    l_line_len := 13 + length(g_table_name);
    l_first_col_set := false;

    if g_pk_column_rec.virtual_column <> 'YES' then
      p_body := p_body || g_pk_column_rec.column_name;
      l_first_col_set := true;
    end if;

    for i in 1 .. g_columns_tbl.count loop
      continue when g_columns_tbl(i).virtual_column = 'YES';
      if l_first_col_set then
        p_body := p_body || ',' || lf || rpad(' ', l_line_len);
      end if;
      p_body := p_body || g_columns_tbl(i).column_name;
      l_first_col_set := true;
    end loop;

    p_body := p_body || ')' || lf || '      values (';
    l_line_len := 14;

    for i in 1 .. l_params_tab.count loop
      if i > 1 then
        p_body := p_body || ',' || lf || rpad(' ', l_line_len);
      end if;
      p_body := p_body || l_params_tab(i);
    end loop;

    p_body := p_body || ')' ||  lf
                     || '    returning ' || g_pk_column_rec.column_name || ' into ' || l_res_var_name || ';' || lf2
                     || '    return ' || l_res_var_name || ';' || lf2
                     || '  exception' || lf
                     || '    when others then' || lf
                     || '      raise_application_error(-20001, dbms_utility.format_error_stack);' || lf
                     || '  end ' || l_name || ';' || lf2;

    p_body := lower(p_body);
    p_spec := lower(p_spec);

    if func_doc is not null then
      p_body := format_doc(func_doc, l_name, l_params_tab) || lf || p_body;
      p_spec := format_doc(func_doc, l_name, l_params_tab) || lf || p_spec;
    end if;

  exception
    when others then
      raise_application_error(-20000, dbms_utility.format_error_stack);
  end gen_ins_func;

  /**
   * Generates a procedure that delete row from the table by PK value.
   * @param p_spec - generated code for package spec
   * @param p_body - generated code for package body
   */
  procedure gen_del_proc(p_spec  out varchar2,
                         p_body  out varchar2)
  is
    l_params_tab  params_tbl;
    l_name        varchar2(128);
  begin
    if not g_initialized then
      raise_application_error(-20001, 'Not initialized');
    end if;
    l_params_tab(1) := get_param_name(g_pk_column_rec.column_name);

    l_name := 'del_'||substr(g_table_name, 1, g_chr_limit-4);
    p_body := '  procedure ' || l_name || '('
                             || l_params_tab(1) || ' '
                             || get_declaration_type(g_pk_column_rec.column_name, g_pk_column_rec.data_type)
                             || ')';

    p_spec := p_body || ';' || lf2;

    p_body := p_body || lf || '  is' || lf || '  begin' || lf2
                     || '    delete from ' || g_table_name || ' ' || g_alias || lf
                     || '     where ' || g_alias || '.' || g_pk_column_rec.column_name
                     || ' = ' || l_params_tab(1) || ';' || lf2
                     || '  exception' || lf
                     || '    when others then' || lf
                     || '      raise_application_error(-20001, dbms_utility.format_error_stack);' || lf
                     || '  end ' || l_name || ';' || lf2;

    p_body := lower(p_body);
    p_spec := lower(p_spec);

    if proc_doc is not null then
      p_body := format_doc(proc_doc, l_name, l_params_tab) || lf || p_body;
      p_spec := format_doc(proc_doc, l_name, l_params_tab) || lf || p_spec;
    end if;

  exception
    when others then
      raise_application_error(-20000, dbms_utility.format_error_stack);
  end gen_del_proc;

  /**
   * Generates a procedure that update all columns of a table except virtual and PK ones by PK value.
   * All parameters are default null except PK.
   * A null value does not overwrite non-null data in a column.
   * @param p_spec - generated code for package spec
   * @param p_body - generated code for package body
   */
  procedure gen_common_upd_proc(p_spec out varchar2,
                                p_body out varchar2)
  is
    l_params_tab  params_tbl;
    l_name        varchar2(128);
    l_line_len    number;
  begin
    if not g_initialized then
      raise_application_error(-20001, 'Not initialized');
    end if;
    l_name := 'upd_'||substr(g_table_name, 1, g_chr_limit-4);
    p_body := '  procedure ' || l_name || '(';
    l_line_len := length(p_body);
    l_params_tab(1) := get_param_name(g_pk_column_rec.column_name);
    p_body := p_body || l_params_tab(1) || ' '
                     || get_declaration_type(g_pk_column_rec.column_name, g_pk_column_rec.data_type);

    for i in 1 .. g_columns_tbl.count loop
      continue when g_columns_tbl(i).virtual_column = 'YES';
      l_params_tab(l_params_tab.count+1) := get_param_name(g_columns_tbl(i).column_name);
      p_body := p_body || ',' || lf || rpad(' ', l_line_len)
                       || l_params_tab(l_params_tab.count) || ' '
                       || get_declaration_type(g_columns_tbl(i).column_name, g_columns_tbl(i).data_type)
                       || ' default null';
    end loop;
    p_body := p_body || ')';
    p_spec := p_body || ';' || lf2;

    p_body := p_body || lf || '  is' || lf || '  begin' || lf2
                     || '    update ' || g_table_name || ' ' || g_alias || lf
                     || '       set ';
    l_line_len := 11;
    for i in 2 .. l_params_tab.count loop
      if i > 2 then
        p_body := p_body || ',' || lf || rpad(' ', l_line_len);
      end if;
      p_body := p_body || g_alias || '.' || g_columns_tbl(i-1).column_name
                   || ' = nvl(' || l_params_tab(i) || ', '
                   || g_alias || '.' || g_columns_tbl(i-1).column_name || ')';
    end loop;

    p_body := p_body || lf || '     where ' || g_alias || '.' || g_pk_column_rec.column_name
                     || ' = ' || l_params_tab(1) || ';' || lf2
                     || '  exception' || lf
                     || '    when others then' || lf
                     || '      raise_application_error(-20001, dbms_utility.format_error_stack);' || lf
                     || '  end ' || l_name || ';' || lf2;

    p_body := lower(p_body);
    p_spec := lower(p_spec);

    if proc_doc is not null then
      p_body := format_doc(proc_doc, l_name, l_params_tab) || lf || p_body;
      p_spec := format_doc(proc_doc, l_name, l_params_tab) || lf || p_spec;
    end if;

  exception
    when others then
      raise_application_error(-20000, dbms_utility.format_error_stack);
  end gen_common_upd_proc;

  /**
   * Generates a procedure that update one column of a table by PK value.
   * @param p_col_indx - index in the column collection for which the procedure is being created
   * @param p_spec     - generated code for package spec
   * @param p_body     - generated code for package body
   */
  procedure gen_upd_proc(p_col_indx in  integer,
                         p_spec     out varchar2,
                         p_body     out varchar2)
  is
    l_params_tab  params_tbl;
    l_name        varchar2(128);
    l_line_len    number;
  begin
    if not g_initialized then
      raise_application_error(-20001, 'Not initialized');
    end if;

    if g_columns_tbl(p_col_indx).virtual_column = 'YES' then
      raise_application_error(-20005, 'Imposible to update virtual column');
    end if;

    l_name := 'upd_'||substr(g_columns_tbl(p_col_indx).column_name, 1, g_chr_limit-4);
    p_body := '  procedure ' || l_name || '(';
    l_line_len := length(p_body);
    l_params_tab(1) := get_param_name(g_pk_column_rec.column_name);
    l_params_tab(2) := get_param_name(g_columns_tbl(p_col_indx).column_name);

    p_body := p_body || l_params_tab(1) || ' '
                     || get_declaration_type(g_pk_column_rec.column_name, g_pk_column_rec.data_type)
                     || ',' || lf || rpad(' ', l_line_len)
                     || l_params_tab(2) || ' '
                     || get_declaration_type(g_columns_tbl(p_col_indx).column_name, g_columns_tbl(p_col_indx).data_type)
                     || ')';

    p_spec := p_body || ';' || lf2;

    p_body := p_body || lf || '  is' || lf || '  begin' || lf2
                     || '    update ' || g_table_name || ' ' || g_alias || lf
                     || '       set ' || g_alias || '.' || g_columns_tbl(p_col_indx).column_name
                     || ' = ' || l_params_tab(2) || lf
                     || '     where ' || g_alias || '.' || g_pk_column_rec.column_name
                     || ' = ' || l_params_tab(1) || ';' || lf2
                     || '  exception' || lf
                     || '    when others then' || lf
                     || '      raise_application_error(-20001, dbms_utility.format_error_stack);' || lf
                     || '  end ' || l_name || ';' || lf2;

    p_body := lower(p_body);
    p_spec := lower(p_spec);

    if proc_doc is not null then
      p_body := format_doc(proc_doc, l_name, l_params_tab) || lf || p_body;
      p_spec := format_doc(proc_doc, l_name, l_params_tab) || lf || p_spec;
    end if;

  exception
    when others then
      raise_application_error(-20000, dbms_utility.format_error_stack);
  end gen_upd_proc;

  /**
   * Generates a function that checks if record exist in a table by PK and returns boolean
   * @param p_spec - generated code for package spec
   * @param p_body - generated code for package body
   */
  procedure gen_exist_func(p_spec out varchar2,
                           p_body out varchar2)
  is
    l_params_tab    params_tbl;
    l_name          varchar2(128);
    l_res_var_name  varchar2(128) := get_var_name('result');
  begin
    if not g_initialized then
      raise_application_error(-20001, 'Not initialized');
    end if;

    l_name := 'exists_'||substr(g_table_name, 1, g_chr_limit-7);
    p_body := '  function ' || l_name || '(';
    l_params_tab(1) := get_param_name(g_pk_column_rec.column_name);

    p_body := p_body || l_params_tab(1) ||' '
                     || get_declaration_type(g_pk_column_rec.column_name, g_pk_column_rec.data_type)
                     || ')' || lf || '  return boolean';

    p_spec := p_body || ';' || lf2;

    p_body := p_body || lf || '  is' || lf || '    ' || l_res_var_name || ' integer;' || lf
                     || '  begin' || lf2
                     || '    select case' || lf
                     || '             when exists (select 1' || lf
                     || '                            from ' || g_table_name || ' ' || g_alias ||lf
                     || '                           where ' || g_alias || '.'
                     || g_pk_column_rec.column_name || ' = ' || l_params_tab(1) || ')' || lf
                     || '             then 1' || lf
                     || '             else 0' || lf
                     || '           end' || lf
                     || '      into ' || l_res_var_name || lf
                     || '      from dual;' || lf2
                     || '    return ' || l_res_var_name || ' = 1;' || lf2
                     || '  exception' || lf
                     || '    when others then' || lf
                     || '      raise_application_error(-20001, dbms_utility.format_error_stack);' || lf
                     || '  end ' || l_name || ';' || lf2;

    p_body := lower(p_body);
    p_spec := lower(p_spec);

    if func_doc is not null then
      p_body := format_doc(func_doc, l_name, l_params_tab) || lf || p_body;
      p_spec := format_doc(func_doc, l_name, l_params_tab) || lf || p_spec;
    end if;

  exception
    when others then
      raise_application_error(-20000, dbms_utility.format_error_stack);
  end gen_exist_func;

  /**
   * Generates a function that returns one column value of a table by PK
   * @param p_col_indx - index in the column collection for which the function is being created
   * @param p_spec     - generated code for package spec
   * @param p_body     - generated code for package body
   */
  procedure gen_sel_func(p_col_indx in  integer,
                         p_spec     out varchar2,
                         p_body     out varchar2)
  is
    l_params_tab    params_tbl;
    l_name          varchar2(128);
    l_res_var_name  varchar2(128) := get_var_name('result');
  begin
    if not g_initialized then
      raise_application_error(-20001, 'Not initialized');
    end if;

    l_name := 'get_'||substr(g_columns_tbl(p_col_indx).column_name, 1, g_chr_limit-4);
    p_body := '  function ' || l_name || '(';
    l_params_tab(1) := get_param_name(g_pk_column_rec.column_name);

    p_body := p_body || l_params_tab(1) ||' '
                     || get_declaration_type(g_pk_column_rec.column_name, g_pk_column_rec.data_type)
                     || ')' || lf || '  return '
                     || get_declaration_type(g_columns_tbl(p_col_indx).column_name,
                                             get_data_type(g_columns_tbl(p_col_indx).data_type,
                                                           g_columns_tbl(p_col_indx).data_precision,
                                                           g_columns_tbl(p_col_indx).data_scale,
                                                           p_add_precision => false));

    p_spec := p_body || ';' || lf2;

    p_body := p_body || lf || '  is' || lf || '    ' || l_res_var_name || ' '
                     || get_declaration_type(g_columns_tbl(p_col_indx).column_name,
                                             get_data_type(g_columns_tbl(p_col_indx).data_type,
                                                           g_columns_tbl(p_col_indx).data_precision,
                                                           g_columns_tbl(p_col_indx).data_scale,
                                                           g_columns_tbl(p_col_indx).char_length,
                                                           g_columns_tbl(p_col_indx).char_used))
                     || ';' || lf || '  begin' || lf2
                     || '    select ' || g_alias || '.' || g_columns_tbl(p_col_indx).column_name || lf
                     || '      into ' || l_res_var_name || lf
                     || '      from ' || g_table_name || ' ' || g_alias || lf
                     || '     where ' || g_alias || '.' || g_pk_column_rec.column_name
                     || ' = ' || l_params_tab(1) || ';' || lf2
                     || '    return ' || l_res_var_name || ';' || lf2
                     || '  exception' || lf
                     || '    when no_data_found then' || lf
                     || case when use_ndf_ret_null then
                          '      return null;'
                        else
                          '      raise_application_error(-20002, ''Not found record with id='' || ' || l_params_tab(1) || ');'
                        end
                     || lf
                     || '    when others then' || lf
                     || '      raise_application_error(-20001, dbms_utility.format_error_stack);' || lf
                     || '  end ' || l_name || ';' || lf2;

    p_body := lower(p_body);
    p_spec := lower(p_spec);

    if func_doc is not null then
      p_body := format_doc(func_doc, l_name, l_params_tab) || lf || p_body;
      p_spec := format_doc(func_doc, l_name, l_params_tab) || lf || p_spec;
    end if;

  exception
    when others then
      raise_application_error(-20000, dbms_utility.format_error_stack);
  end gen_sel_func;

  /**
   * Generates into output package code with all functions and procedures
   */
  procedure generate
  is
    l_tmp_spec varchar2(32767);
    l_tmp_body varchar2(32767);
    l_pkg_spec clob;
    l_pkg_body clob;

    procedure append_data_to_clob(p_spec varchar2,
                                  p_body varchar2)
    is
    begin
      if p_spec is not null then
        dbms_lob.writeappend(l_pkg_spec, length(l_tmp_spec), l_tmp_spec);
      end if;
      if p_body is not null then
        dbms_lob.writeappend(l_pkg_body, length(l_tmp_body), l_tmp_body);
      end if;
    end append_data_to_clob;

    procedure print_clob (p_clob clob)
    is
      l_offset  integer := 1;
      l_pos     integer;
      l_length  integer;
      l_ammount integer;
    begin
      l_length := dbms_lob.getlength(p_clob);
      loop
        exit when l_offset > l_length;
        l_pos := dbms_lob.instr(p_clob, lf2, l_offset);
        if l_pos = 0 then
          l_ammount := l_length;
          else
          l_ammount := l_pos - l_offset;
        end if;
        dbms_output.put_line(dbms_lob.substr(p_clob, l_ammount, l_offset));
        l_offset := l_offset + l_ammount + 1;
      end loop;
    end print_clob;

  begin
    if not g_initialized then
      raise_application_error(-20001, 'Not initialized');
    end if;

    l_tmp_spec := 'create or replace package ' || g_pkg_name || ' as' || lf;
    l_tmp_body := 'create or replace package body ' || g_pkg_name || ' as' || lf;
    if pkg_doc is not null then
      l_tmp_spec := l_tmp_spec || format_doc(pkg_doc, pkg_doc) || lf;
      l_tmp_body := l_tmp_body || format_doc(pkg_doc, pkg_doc) || lf;
    end if;
    l_tmp_spec := l_tmp_spec || lf;
    l_tmp_body := l_tmp_body || lf;

    dbms_lob.createtemporary(l_pkg_spec, true);
    dbms_lob.createtemporary(l_pkg_body, true);
    append_data_to_clob(l_tmp_spec, l_tmp_body);

    if print_ins_proc then
      gen_ins_proc(l_tmp_spec, l_tmp_body);
      append_data_to_clob(l_tmp_spec, l_tmp_body);
    end if;

    if print_ins_func then
      gen_ins_func(l_tmp_spec, l_tmp_body);
      append_data_to_clob(l_tmp_spec, l_tmp_body);
    end if;

    if print_del_proc then
      gen_del_proc(l_tmp_spec, l_tmp_body);
      append_data_to_clob(l_tmp_spec, l_tmp_body);
    end if;

    if g_columns_tbl.count > 0 and print_common_upd_proc then
      gen_common_upd_proc(l_tmp_spec, l_tmp_body);
      append_data_to_clob(l_tmp_spec, l_tmp_body);
    end if;

    if print_upd_proc then
      for indx in 1 .. g_columns_tbl.count loop
        continue when g_columns_tbl(indx).virtual_column = 'YES'
                   or g_columns_tbl(indx).column_name member of g_update_excluded_cols;
        gen_upd_proc(indx, l_tmp_spec, l_tmp_body);
        append_data_to_clob(l_tmp_spec, l_tmp_body);
      end loop;
    end if;

    if print_exist_func then
      gen_exist_func(l_tmp_spec, l_tmp_body);
      append_data_to_clob(l_tmp_spec, l_tmp_body);
    end if;

    if print_select_funcs then
      for indx in 1 .. g_columns_tbl.count loop
        continue when g_columns_tbl(indx).column_name member of g_select_excluded_cols;
        gen_sel_func(indx, l_tmp_spec, l_tmp_body);
        append_data_to_clob(l_tmp_spec, l_tmp_body);
      end loop;
    end if;

    l_tmp_spec := 'end ' || g_pkg_name || ';' || lf || '/' || lf;
    l_tmp_body := 'end ' || g_pkg_name || ';' || lf || '/' || lf;
    append_data_to_clob(l_tmp_spec, l_tmp_body);

    dbms_output.enable(null);
    print_clob(l_pkg_spec);
    print_clob(l_pkg_body);

    dbms_lob.freetemporary(l_pkg_body);
    dbms_lob.freetemporary(l_pkg_spec);
  exception
    when others then
      raise_application_error(-20000, dbms_utility.format_error_stack
                                      || dbms_utility.format_error_backtrace);
  end generate;

  /**
   * Generates a procedure that inserts data into a table.
   * As parameters, all columns of the table are used except virtual ones.
   * For nullable columns, the parameters are set to the default null.
   * @return - generated code
   */
  function gen_ins_proc
  return varchar2
  is
    l_tmp_spec varchar2(32767);
    l_tmp_body varchar2(32767);
  begin
    gen_ins_proc(l_tmp_spec, l_tmp_body);
    return l_tmp_body;
  end gen_ins_proc;

  /**
   * Generates a function that inserts data into a table and returns PK value of created row.
   * As parameters, all columns of the table are used except virtual ones.
   * For nullable columns, the parameters are set to the default null.
   * @return - generated code
   */
  function gen_ins_func
  return varchar2
  is
    l_tmp_spec varchar2(32767);
    l_tmp_body varchar2(32767);
  begin
    gen_ins_func(l_tmp_spec, l_tmp_body);
    return l_tmp_body;
  end gen_ins_func;

  /**
   * Generates a procedure that delete row from the table by PK value.
   * @return - generated code
   */
  function gen_del_proc
  return varchar2
  is
    l_tmp_spec varchar2(32767);
    l_tmp_body varchar2(32767);
  begin
    gen_del_proc(l_tmp_spec, l_tmp_body);
    return l_tmp_body;
  end gen_del_proc;

  /**
   * Generates a procedure that update all columns of a table except virtual and PK ones by PK value.
   * All parameters are default null except PK.
   * A null value does not overwrite non-null data in a column.
   * @return - generated code
   */
  function gen_common_upd_proc
  return varchar2
  is
    l_tmp_spec varchar2(32767);
    l_tmp_body varchar2(32767);
  begin
    gen_common_upd_proc(l_tmp_spec, l_tmp_body);
    return l_tmp_body;
  end gen_common_upd_proc;

  /**
   * Generates a procedure that update one column of a table by PK value.
   * @param p_col_indx - index in the column collection for which the procedure is being created
   * @return - generated code
   */
  function gen_upd_proc(p_col_indx integer)
  return varchar2
  is
    l_tmp_spec varchar2(32767);
    l_tmp_body varchar2(32767);
  begin
    gen_upd_proc(p_col_indx, l_tmp_spec, l_tmp_body);
    return l_tmp_body;
  end gen_upd_proc;

  /**
   * Generates a function that checks if record exist in a table by PK and returns boolean.
   * @return - generated code
   */
  function gen_exist_func
  return varchar2
  is
    l_tmp_spec varchar2(32767);
    l_tmp_body varchar2(32767);
  begin
    gen_exist_func(l_tmp_spec, l_tmp_body);
    return l_tmp_body;
  end gen_exist_func;

  /**
   * Generates a function that returns one column value of a table by PK.
   * @param p_col_indx - index in the column collection for which the function is being created
   * @return - generated code
   */
  function gen_sel_func(p_col_indx integer)
  return varchar2
  is
    l_tmp_spec varchar2(32767);
    l_tmp_body varchar2(32767);
  begin
    gen_sel_func(p_col_indx, l_tmp_spec, l_tmp_body);
    return l_tmp_body;
  end gen_sel_func;

begin

  -- see procedure documentation and fill the parameters
  init(p_table_name     => 'table name',
       p_owner          => user(),
       p_pk_column      => 'table pk column',
       p_pkg_name       => 'new package name',
       p_name_chr_limit => 30);

  -- generates package into output
  generate;

end;
/