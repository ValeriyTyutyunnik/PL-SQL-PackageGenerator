create or replace package employees_funcs as
/** TODO: add package documentation here
 * @created 12.01.2020
 * @author Batman
 * @version 1.0
 */

  /** Procedure: ins_employees
   * Purpose: TODO add procedure documentation here
   * @author Batman
   * @created 12.01.2020
   * @version 1.0
   * =========================================
   * @param p_employee_id -
   * @param p_first_name -
   * @param p_last_name -
   * @param p_email -
   * @param p_phone_number -
   * @param p_hire_date -
   * @param p_job_id -
   * @param p_salary -
   * @param p_commission_pct -
   * @param p_manager_id -
   * @param p_department_id -
   * @throws
   */
  procedure ins_employees(p_employee_id employees.employee_id%type,
                          p_first_name employees.first_name%type default null,
                          p_last_name employees.last_name%type,
                          p_email employees.email%type,
                          p_phone_number employees.phone_number%type default null,
                          p_hire_date employees.hire_date%type,
                          p_job_id employees.job_id%type,
                          p_salary employees.salary%type default null,
                          p_commission_pct employees.commission_pct%type default null,
                          p_manager_id employees.manager_id%type default null,
                          p_department_id employees.department_id%type default null);

  /** Function: ins_employees
   * Purpose: TODO add function documentation here
   * @author Batman
   * @created 12.01.2020
   * @version 1.0
   * =========================================
   * @param p_employee_id -
   * @param p_first_name -
   * @param p_last_name -
   * @param p_email -
   * @param p_phone_number -
   * @param p_hire_date -
   * @param p_job_id -
   * @param p_salary -
   * @param p_commission_pct -
   * @param p_manager_id -
   * @param p_department_id -
   * @return
   * @throws
   */
  function ins_employees(p_employee_id employees.employee_id%type,
                         p_first_name employees.first_name%type default null,
                         p_last_name employees.last_name%type,
                         p_email employees.email%type,
                         p_phone_number employees.phone_number%type default null,
                         p_hire_date employees.hire_date%type,
                         p_job_id employees.job_id%type,
                         p_salary employees.salary%type default null,
                         p_commission_pct employees.commission_pct%type default null,
                         p_manager_id employees.manager_id%type default null,
                         p_department_id employees.department_id%type default null)
  return employees.employee_id%type;

  /** Procedure: del_employees
   * Purpose: TODO add procedure documentation here
   * @author Batman
   * @created 12.01.2020
   * @version 1.0
   * =========================================
   * @param p_employee_id -
   * @throws
   */
  procedure del_employees(p_employee_id employees.employee_id%type);

  /** Procedure: upd_employees
   * Purpose: TODO add procedure documentation here
   * @author Batman
   * @created 12.01.2020
   * @version 1.0
   * =========================================
   * @param p_employee_id -
   * @param p_first_name -
   * @param p_last_name -
   * @param p_email -
   * @param p_phone_number -
   * @param p_hire_date -
   * @param p_job_id -
   * @param p_salary -
   * @param p_commission_pct -
   * @param p_manager_id -
   * @param p_department_id -
   * @throws
   */
  procedure upd_employees(p_employee_id employees.employee_id%type,
                          p_first_name employees.first_name%type default null,
                          p_last_name employees.last_name%type default null,
                          p_email employees.email%type default null,
                          p_phone_number employees.phone_number%type default null,
                          p_hire_date employees.hire_date%type default null,
                          p_job_id employees.job_id%type default null,
                          p_salary employees.salary%type default null,
                          p_commission_pct employees.commission_pct%type default null,
                          p_manager_id employees.manager_id%type default null,
                          p_department_id employees.department_id%type default null);

  /** Procedure: upd_last_name
   * Purpose: TODO add procedure documentation here
   * @author Batman
   * @created 12.01.2020
   * @version 1.0
   * =========================================
   * @param p_employee_id -
   * @param p_last_name -
   * @throws
   */
  procedure upd_last_name(p_employee_id employees.employee_id%type,
                          p_last_name employees.last_name%type);

  /** Procedure: upd_email
   * Purpose: TODO add procedure documentation here
   * @author Batman
   * @created 12.01.2020
   * @version 1.0
   * =========================================
   * @param p_employee_id -
   * @param p_email -
   * @throws
   */
  procedure upd_email(p_employee_id employees.employee_id%type,
                      p_email employees.email%type);

  /** Procedure: upd_phone_number
   * Purpose: TODO add procedure documentation here
   * @author Batman
   * @created 12.01.2020
   * @version 1.0
   * =========================================
   * @param p_employee_id -
   * @param p_phone_number -
   * @throws
   */
  procedure upd_phone_number(p_employee_id employees.employee_id%type,
                             p_phone_number employees.phone_number%type);

  /** Procedure: upd_job_id
   * Purpose: TODO add procedure documentation here
   * @author Batman
   * @created 12.01.2020
   * @version 1.0
   * =========================================
   * @param p_employee_id -
   * @param p_job_id -
   * @throws
   */
  procedure upd_job_id(p_employee_id employees.employee_id%type,
                       p_job_id employees.job_id%type);

  /** Procedure: upd_salary
   * Purpose: TODO add procedure documentation here
   * @author Batman
   * @created 12.01.2020
   * @version 1.0
   * =========================================
   * @param p_employee_id -
   * @param p_salary -
   * @throws
   */
  procedure upd_salary(p_employee_id employees.employee_id%type,
                       p_salary employees.salary%type);

  /** Procedure: upd_commission_pct
   * Purpose: TODO add procedure documentation here
   * @author Batman
   * @created 12.01.2020
   * @version 1.0
   * =========================================
   * @param p_employee_id -
   * @param p_commission_pct -
   * @throws
   */
  procedure upd_commission_pct(p_employee_id employees.employee_id%type,
                               p_commission_pct employees.commission_pct%type);

  /** Procedure: upd_manager_id
   * Purpose: TODO add procedure documentation here
   * @author Batman
   * @created 12.01.2020
   * @version 1.0
   * =========================================
   * @param p_employee_id -
   * @param p_manager_id -
   * @throws
   */
  procedure upd_manager_id(p_employee_id employees.employee_id%type,
                           p_manager_id employees.manager_id%type);

  /** Procedure: upd_department_id
   * Purpose: TODO add procedure documentation here
   * @author Batman
   * @created 12.01.2020
   * @version 1.0
   * =========================================
   * @param p_employee_id -
   * @param p_department_id -
   * @throws
   */
  procedure upd_department_id(p_employee_id employees.employee_id%type,
                              p_department_id employees.department_id%type);

  /** Function: exists_employees
   * Purpose: TODO add function documentation here
   * @author Batman
   * @created 12.01.2020
   * @version 1.0
   * =========================================
   * @param p_employee_id -
   * @return
   * @throws
   */
  function exists_employees(p_employee_id employees.employee_id%type)
  return boolean;

  /** Function: get_first_name
   * Purpose: TODO add function documentation here
   * @author Batman
   * @created 12.01.2020
   * @version 1.0
   * =========================================
   * @param p_employee_id -
   * @return
   * @throws
   */
  function get_first_name(p_employee_id employees.employee_id%type)
  return employees.first_name%type;

  /** Function: get_last_name
   * Purpose: TODO add function documentation here
   * @author Batman
   * @created 12.01.2020
   * @version 1.0
   * =========================================
   * @param p_employee_id -
   * @return
   * @throws
   */
  function get_last_name(p_employee_id employees.employee_id%type)
  return employees.last_name%type;

  /** Function: get_email
   * Purpose: TODO add function documentation here
   * @author Batman
   * @created 12.01.2020
   * @version 1.0
   * =========================================
   * @param p_employee_id -
   * @return
   * @throws
   */
  function get_email(p_employee_id employees.employee_id%type)
  return employees.email%type;

  /** Function: get_phone_number
   * Purpose: TODO add function documentation here
   * @author Batman
   * @created 12.01.2020
   * @version 1.0
   * =========================================
   * @param p_employee_id -
   * @return
   * @throws
   */
  function get_phone_number(p_employee_id employees.employee_id%type)
  return employees.phone_number%type;

  /** Function: get_hire_date
   * Purpose: TODO add function documentation here
   * @author Batman
   * @created 12.01.2020
   * @version 1.0
   * =========================================
   * @param p_employee_id -
   * @return
   * @throws
   */
  function get_hire_date(p_employee_id employees.employee_id%type)
  return employees.hire_date%type;

  /** Function: get_salary
   * Purpose: TODO add function documentation here
   * @author Batman
   * @created 12.01.2020
   * @version 1.0
   * =========================================
   * @param p_employee_id -
   * @return
   * @throws
   */
  function get_salary(p_employee_id employees.employee_id%type)
  return employees.salary%type;

  /** Function: get_commission_pct
   * Purpose: TODO add function documentation here
   * @author Batman
   * @created 12.01.2020
   * @version 1.0
   * =========================================
   * @param p_employee_id -
   * @return
   * @throws
   */
  function get_commission_pct(p_employee_id employees.employee_id%type)
  return employees.commission_pct%type;

  /** Function: get_manager_id
   * Purpose: TODO add function documentation here
   * @author Batman
   * @created 12.01.2020
   * @version 1.0
   * =========================================
   * @param p_employee_id -
   * @return
   * @throws
   */
  function get_manager_id(p_employee_id employees.employee_id%type)
  return employees.manager_id%type;

  /** Function: get_department_id
   * Purpose: TODO add function documentation here
   * @author Batman
   * @created 12.01.2020
   * @version 1.0
   * =========================================
   * @param p_employee_id -
   * @return
   * @throws
   */
  function get_department_id(p_employee_id employees.employee_id%type)
  return employees.department_id%type;

end employees_funcs;
/

create or replace package body employees_funcs as
/** TODO: add package documentation here
 * @created 12.01.2020
 * @author Batman
 * @version 1.0
 */

  /** Procedure: ins_employees
   * Purpose: TODO add procedure documentation here
   * @author Batman
   * @created 12.01.2020
   * @version 1.0
   * =========================================
   * @param p_employee_id -
   * @param p_first_name -
   * @param p_last_name -
   * @param p_email -
   * @param p_phone_number -
   * @param p_hire_date -
   * @param p_job_id -
   * @param p_salary -
   * @param p_commission_pct -
   * @param p_manager_id -
   * @param p_department_id -
   * @throws
   */
  procedure ins_employees(p_employee_id employees.employee_id%type,
                          p_first_name employees.first_name%type default null,
                          p_last_name employees.last_name%type,
                          p_email employees.email%type,
                          p_phone_number employees.phone_number%type default null,
                          p_hire_date employees.hire_date%type,
                          p_job_id employees.job_id%type,
                          p_salary employees.salary%type default null,
                          p_commission_pct employees.commission_pct%type default null,
                          p_manager_id employees.manager_id%type default null,
                          p_department_id employees.department_id%type default null)
  is
  begin

    insert
      into employees (employee_id,
                      first_name,
                      last_name,
                      email,
                      phone_number,
                      hire_date,
                      job_id,
                      salary,
                      commission_pct,
                      manager_id,
                      department_id)
      values (p_employee_id,
              p_first_name,
              p_last_name,
              p_email,
              p_phone_number,
              p_hire_date,
              p_job_id,
              p_salary,
              p_commission_pct,
              p_manager_id,
              p_department_id);

  exception
    when others then
      raise_application_error(-20001, dbms_utility.format_error_stack);
  end ins_employees;

  /** Function: ins_employees
   * Purpose: TODO add function documentation here
   * @author Batman
   * @created 12.01.2020
   * @version 1.0
   * =========================================
   * @param p_employee_id -
   * @param p_first_name -
   * @param p_last_name -
   * @param p_email -
   * @param p_phone_number -
   * @param p_hire_date -
   * @param p_job_id -
   * @param p_salary -
   * @param p_commission_pct -
   * @param p_manager_id -
   * @param p_department_id -
   * @return
   * @throws
   */
  function ins_employees(p_employee_id employees.employee_id%type,
                         p_first_name employees.first_name%type default null,
                         p_last_name employees.last_name%type,
                         p_email employees.email%type,
                         p_phone_number employees.phone_number%type default null,
                         p_hire_date employees.hire_date%type,
                         p_job_id employees.job_id%type,
                         p_salary employees.salary%type default null,
                         p_commission_pct employees.commission_pct%type default null,
                         p_manager_id employees.manager_id%type default null,
                         p_department_id employees.department_id%type default null)
  return employees.employee_id%type
  is
    l_result employees.employee_id%type;
  begin

    insert
      into employees (employee_id,
                      first_name,
                      last_name,
                      email,
                      phone_number,
                      hire_date,
                      job_id,
                      salary,
                      commission_pct,
                      manager_id,
                      department_id)
      values (p_employee_id,
              p_first_name,
              p_last_name,
              p_email,
              p_phone_number,
              p_hire_date,
              p_job_id,
              p_salary,
              p_commission_pct,
              p_manager_id,
              p_department_id)
    returning employee_id into l_result;

    return l_result;

  exception
    when others then
      raise_application_error(-20001, dbms_utility.format_error_stack);
  end ins_employees;

  /** Procedure: del_employees
   * Purpose: TODO add procedure documentation here
   * @author Batman
   * @created 12.01.2020
   * @version 1.0
   * =========================================
   * @param p_employee_id -
   * @throws
   */
  procedure del_employees(p_employee_id employees.employee_id%type)
  is
  begin

    delete from employees e
     where e.employee_id = p_employee_id;

  exception
    when others then
      raise_application_error(-20001, dbms_utility.format_error_stack);
  end del_employees;

  /** Procedure: upd_employees
   * Purpose: TODO add procedure documentation here
   * @author Batman
   * @created 12.01.2020
   * @version 1.0
   * =========================================
   * @param p_employee_id -
   * @param p_first_name -
   * @param p_last_name -
   * @param p_email -
   * @param p_phone_number -
   * @param p_hire_date -
   * @param p_job_id -
   * @param p_salary -
   * @param p_commission_pct -
   * @param p_manager_id -
   * @param p_department_id -
   * @throws
   */
  procedure upd_employees(p_employee_id employees.employee_id%type,
                          p_first_name employees.first_name%type default null,
                          p_last_name employees.last_name%type default null,
                          p_email employees.email%type default null,
                          p_phone_number employees.phone_number%type default null,
                          p_hire_date employees.hire_date%type default null,
                          p_job_id employees.job_id%type default null,
                          p_salary employees.salary%type default null,
                          p_commission_pct employees.commission_pct%type default null,
                          p_manager_id employees.manager_id%type default null,
                          p_department_id employees.department_id%type default null)
  is
  begin

    update employees e
       set e.first_name = nvl(p_first_name, e.first_name),
           e.last_name = nvl(p_last_name, e.last_name),
           e.email = nvl(p_email, e.email),
           e.phone_number = nvl(p_phone_number, e.phone_number),
           e.hire_date = nvl(p_hire_date, e.hire_date),
           e.job_id = nvl(p_job_id, e.job_id),
           e.salary = nvl(p_salary, e.salary),
           e.commission_pct = nvl(p_commission_pct, e.commission_pct),
           e.manager_id = nvl(p_manager_id, e.manager_id),
           e.department_id = nvl(p_department_id, e.department_id)
     where e.employee_id = p_employee_id;

  exception
    when others then
      raise_application_error(-20001, dbms_utility.format_error_stack);
  end upd_employees;

  /** Procedure: upd_last_name
   * Purpose: TODO add procedure documentation here
   * @author Batman
   * @created 12.01.2020
   * @version 1.0
   * =========================================
   * @param p_employee_id -
   * @param p_last_name -
   * @throws
   */
  procedure upd_last_name(p_employee_id employees.employee_id%type,
                          p_last_name employees.last_name%type)
  is
  begin

    update employees e
       set e.last_name = p_last_name
     where e.employee_id = p_employee_id;

  exception
    when others then
      raise_application_error(-20001, dbms_utility.format_error_stack);
  end upd_last_name;

  /** Procedure: upd_email
   * Purpose: TODO add procedure documentation here
   * @author Batman
   * @created 12.01.2020
   * @version 1.0
   * =========================================
   * @param p_employee_id -
   * @param p_email -
   * @throws
   */
  procedure upd_email(p_employee_id employees.employee_id%type,
                      p_email employees.email%type)
  is
  begin

    update employees e
       set e.email = p_email
     where e.employee_id = p_employee_id;

  exception
    when others then
      raise_application_error(-20001, dbms_utility.format_error_stack);
  end upd_email;

  /** Procedure: upd_phone_number
   * Purpose: TODO add procedure documentation here
   * @author Batman
   * @created 12.01.2020
   * @version 1.0
   * =========================================
   * @param p_employee_id -
   * @param p_phone_number -
   * @throws
   */
  procedure upd_phone_number(p_employee_id employees.employee_id%type,
                             p_phone_number employees.phone_number%type)
  is
  begin

    update employees e
       set e.phone_number = p_phone_number
     where e.employee_id = p_employee_id;

  exception
    when others then
      raise_application_error(-20001, dbms_utility.format_error_stack);
  end upd_phone_number;

  /** Procedure: upd_job_id
   * Purpose: TODO add procedure documentation here
   * @author Batman
   * @created 12.01.2020
   * @version 1.0
   * =========================================
   * @param p_employee_id -
   * @param p_job_id -
   * @throws
   */
  procedure upd_job_id(p_employee_id employees.employee_id%type,
                       p_job_id employees.job_id%type)
  is
  begin

    update employees e
       set e.job_id = p_job_id
     where e.employee_id = p_employee_id;

  exception
    when others then
      raise_application_error(-20001, dbms_utility.format_error_stack);
  end upd_job_id;

  /** Procedure: upd_salary
   * Purpose: TODO add procedure documentation here
   * @author Batman
   * @created 12.01.2020
   * @version 1.0
   * =========================================
   * @param p_employee_id -
   * @param p_salary -
   * @throws
   */
  procedure upd_salary(p_employee_id employees.employee_id%type,
                       p_salary employees.salary%type)
  is
  begin

    update employees e
       set e.salary = p_salary
     where e.employee_id = p_employee_id;

  exception
    when others then
      raise_application_error(-20001, dbms_utility.format_error_stack);
  end upd_salary;

  /** Procedure: upd_commission_pct
   * Purpose: TODO add procedure documentation here
   * @author Batman
   * @created 12.01.2020
   * @version 1.0
   * =========================================
   * @param p_employee_id -
   * @param p_commission_pct -
   * @throws
   */
  procedure upd_commission_pct(p_employee_id employees.employee_id%type,
                               p_commission_pct employees.commission_pct%type)
  is
  begin

    update employees e
       set e.commission_pct = p_commission_pct
     where e.employee_id = p_employee_id;

  exception
    when others then
      raise_application_error(-20001, dbms_utility.format_error_stack);
  end upd_commission_pct;

  /** Procedure: upd_manager_id
   * Purpose: TODO add procedure documentation here
   * @author Batman
   * @created 12.01.2020
   * @version 1.0
   * =========================================
   * @param p_employee_id -
   * @param p_manager_id -
   * @throws
   */
  procedure upd_manager_id(p_employee_id employees.employee_id%type,
                           p_manager_id employees.manager_id%type)
  is
  begin

    update employees e
       set e.manager_id = p_manager_id
     where e.employee_id = p_employee_id;

  exception
    when others then
      raise_application_error(-20001, dbms_utility.format_error_stack);
  end upd_manager_id;

  /** Procedure: upd_department_id
   * Purpose: TODO add procedure documentation here
   * @author Batman
   * @created 12.01.2020
   * @version 1.0
   * =========================================
   * @param p_employee_id -
   * @param p_department_id -
   * @throws
   */
  procedure upd_department_id(p_employee_id employees.employee_id%type,
                              p_department_id employees.department_id%type)
  is
  begin

    update employees e
       set e.department_id = p_department_id
     where e.employee_id = p_employee_id;

  exception
    when others then
      raise_application_error(-20001, dbms_utility.format_error_stack);
  end upd_department_id;

  /** Function: exists_employees
   * Purpose: TODO add function documentation here
   * @author Batman
   * @created 12.01.2020
   * @version 1.0
   * =========================================
   * @param p_employee_id -
   * @return
   * @throws
   */
  function exists_employees(p_employee_id employees.employee_id%type)
  return boolean
  is
    l_result integer;
  begin

    select case
             when exists (select 1
                            from employees e
                           where e.employee_id = p_employee_id)
             then 1
             else 0
           end
      into l_result
      from dual;

    return l_result = 1;

  exception
    when others then
      raise_application_error(-20001, dbms_utility.format_error_stack);
  end exists_employees;

  /** Function: get_first_name
   * Purpose: TODO add function documentation here
   * @author Batman
   * @created 12.01.2020
   * @version 1.0
   * =========================================
   * @param p_employee_id -
   * @return
   * @throws
   */
  function get_first_name(p_employee_id employees.employee_id%type)
  return employees.first_name%type
  is
    l_result employees.first_name%type;
  begin

    select e.first_name
      into l_result
      from employees e
     where e.employee_id = p_employee_id;

    return l_result;

  exception
    when no_data_found then
      return null;
    when others then
      raise_application_error(-20001, dbms_utility.format_error_stack);
  end get_first_name;

  /** Function: get_last_name
   * Purpose: TODO add function documentation here
   * @author Batman
   * @created 12.01.2020
   * @version 1.0
   * =========================================
   * @param p_employee_id -
   * @return
   * @throws
   */
  function get_last_name(p_employee_id employees.employee_id%type)
  return employees.last_name%type
  is
    l_result employees.last_name%type;
  begin

    select e.last_name
      into l_result
      from employees e
     where e.employee_id = p_employee_id;

    return l_result;

  exception
    when no_data_found then
      return null;
    when others then
      raise_application_error(-20001, dbms_utility.format_error_stack);
  end get_last_name;

  /** Function: get_email
   * Purpose: TODO add function documentation here
   * @author Batman
   * @created 12.01.2020
   * @version 1.0
   * =========================================
   * @param p_employee_id -
   * @return
   * @throws
   */
  function get_email(p_employee_id employees.employee_id%type)
  return employees.email%type
  is
    l_result employees.email%type;
  begin

    select e.email
      into l_result
      from employees e
     where e.employee_id = p_employee_id;

    return l_result;

  exception
    when no_data_found then
      return null;
    when others then
      raise_application_error(-20001, dbms_utility.format_error_stack);
  end get_email;

  /** Function: get_phone_number
   * Purpose: TODO add function documentation here
   * @author Batman
   * @created 12.01.2020
   * @version 1.0
   * =========================================
   * @param p_employee_id -
   * @return
   * @throws
   */
  function get_phone_number(p_employee_id employees.employee_id%type)
  return employees.phone_number%type
  is
    l_result employees.phone_number%type;
  begin

    select e.phone_number
      into l_result
      from employees e
     where e.employee_id = p_employee_id;

    return l_result;

  exception
    when no_data_found then
      return null;
    when others then
      raise_application_error(-20001, dbms_utility.format_error_stack);
  end get_phone_number;

  /** Function: get_hire_date
   * Purpose: TODO add function documentation here
   * @author Batman
   * @created 12.01.2020
   * @version 1.0
   * =========================================
   * @param p_employee_id -
   * @return
   * @throws
   */
  function get_hire_date(p_employee_id employees.employee_id%type)
  return employees.hire_date%type
  is
    l_result employees.hire_date%type;
  begin

    select e.hire_date
      into l_result
      from employees e
     where e.employee_id = p_employee_id;

    return l_result;

  exception
    when no_data_found then
      return null;
    when others then
      raise_application_error(-20001, dbms_utility.format_error_stack);
  end get_hire_date;

  /** Function: get_salary
   * Purpose: TODO add function documentation here
   * @author Batman
   * @created 12.01.2020
   * @version 1.0
   * =========================================
   * @param p_employee_id -
   * @return
   * @throws
   */
  function get_salary(p_employee_id employees.employee_id%type)
  return employees.salary%type
  is
    l_result employees.salary%type;
  begin

    select e.salary
      into l_result
      from employees e
     where e.employee_id = p_employee_id;

    return l_result;

  exception
    when no_data_found then
      return null;
    when others then
      raise_application_error(-20001, dbms_utility.format_error_stack);
  end get_salary;

  /** Function: get_commission_pct
   * Purpose: TODO add function documentation here
   * @author Batman
   * @created 12.01.2020
   * @version 1.0
   * =========================================
   * @param p_employee_id -
   * @return
   * @throws
   */
  function get_commission_pct(p_employee_id employees.employee_id%type)
  return employees.commission_pct%type
  is
    l_result employees.commission_pct%type;
  begin

    select e.commission_pct
      into l_result
      from employees e
     where e.employee_id = p_employee_id;

    return l_result;

  exception
    when no_data_found then
      return null;
    when others then
      raise_application_error(-20001, dbms_utility.format_error_stack);
  end get_commission_pct;

  /** Function: get_manager_id
   * Purpose: TODO add function documentation here
   * @author Batman
   * @created 12.01.2020
   * @version 1.0
   * =========================================
   * @param p_employee_id -
   * @return
   * @throws
   */
  function get_manager_id(p_employee_id employees.employee_id%type)
  return employees.manager_id%type
  is
    l_result employees.manager_id%type;
  begin

    select e.manager_id
      into l_result
      from employees e
     where e.employee_id = p_employee_id;

    return l_result;

  exception
    when no_data_found then
      return null;
    when others then
      raise_application_error(-20001, dbms_utility.format_error_stack);
  end get_manager_id;

  /** Function: get_department_id
   * Purpose: TODO add function documentation here
   * @author Batman
   * @created 12.01.2020
   * @version 1.0
   * =========================================
   * @param p_employee_id -
   * @return
   * @throws
   */
  function get_department_id(p_employee_id employees.employee_id%type)
  return employees.department_id%type
  is
    l_result employees.department_id%type;
  begin

    select e.department_id
      into l_result
      from employees e
     where e.employee_id = p_employee_id;

    return l_result;

  exception
    when no_data_found then
      return null;
    when others then
      raise_application_error(-20001, dbms_utility.format_error_stack);
  end get_department_id;

end employees_funcs;
/


