create or replace package employees_pkg as

  procedure ins_employees(p_employee_id number,
                          p_first_name varchar2 default null,
                          p_last_name varchar2,
                          p_email varchar2,
                          p_phone_number varchar2 default null,
                          p_hire_date date,
                          p_job_id varchar2,
                          p_salary number default null,
                          p_commission_pct number default null,
                          p_manager_id number default null,
                          p_department_id number default null);

  function ins_employees(p_employee_id number,
                         p_first_name varchar2 default null,
                         p_last_name varchar2,
                         p_email varchar2,
                         p_phone_number varchar2 default null,
                         p_hire_date date,
                         p_job_id varchar2,
                         p_salary number default null,
                         p_commission_pct number default null,
                         p_manager_id number default null,
                         p_department_id number default null)
  return number;

  procedure del_employees(p_employee_id number);

  procedure upd_employees(p_employee_id number,
                          p_first_name varchar2 default null,
                          p_last_name varchar2 default null,
                          p_email varchar2 default null,
                          p_phone_number varchar2 default null,
                          p_hire_date date default null,
                          p_job_id varchar2 default null,
                          p_salary number default null,
                          p_commission_pct number default null,
                          p_manager_id number default null,
                          p_department_id number default null);

  procedure upd_first_name(p_employee_id number,
                           p_first_name varchar2);

  procedure upd_last_name(p_employee_id number,
                          p_last_name varchar2);

  procedure upd_email(p_employee_id number,
                      p_email varchar2);

  procedure upd_phone_number(p_employee_id number,
                             p_phone_number varchar2);

  procedure upd_hire_date(p_employee_id number,
                          p_hire_date date);

  procedure upd_job_id(p_employee_id number,
                       p_job_id varchar2);

  procedure upd_salary(p_employee_id number,
                       p_salary number);

  procedure upd_commission_pct(p_employee_id number,
                               p_commission_pct number);

  procedure upd_manager_id(p_employee_id number,
                           p_manager_id number);

  procedure upd_department_id(p_employee_id number,
                              p_department_id number);

  function exists_employees(p_employee_id number)
  return boolean;

  function get_first_name(p_employee_id number)
  return varchar2;

  function get_last_name(p_employee_id number)
  return varchar2;

  function get_email(p_employee_id number)
  return varchar2;

  function get_phone_number(p_employee_id number)
  return varchar2;

  function get_hire_date(p_employee_id number)
  return date;

  function get_job_id(p_employee_id number)
  return varchar2;

  function get_salary(p_employee_id number)
  return number;

  function get_commission_pct(p_employee_id number)
  return number;

  function get_manager_id(p_employee_id number)
  return number;

  function get_department_id(p_employee_id number)
  return number;

end employees_pkg;
/

create or replace package body employees_pkg as

  procedure ins_employees(p_employee_id number,
                          p_first_name varchar2 default null,
                          p_last_name varchar2,
                          p_email varchar2,
                          p_phone_number varchar2 default null,
                          p_hire_date date,
                          p_job_id varchar2,
                          p_salary number default null,
                          p_commission_pct number default null,
                          p_manager_id number default null,
                          p_department_id number default null)
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

  function ins_employees(p_employee_id number,
                         p_first_name varchar2 default null,
                         p_last_name varchar2,
                         p_email varchar2,
                         p_phone_number varchar2 default null,
                         p_hire_date date,
                         p_job_id varchar2,
                         p_salary number default null,
                         p_commission_pct number default null,
                         p_manager_id number default null,
                         p_department_id number default null)
  return number
  is
    l_result number(6, 0);
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

  procedure del_employees(p_employee_id number)
  is
  begin

    delete from employees e
     where e.employee_id = p_employee_id;

  exception
    when others then
      raise_application_error(-20001, dbms_utility.format_error_stack);
  end del_employees;

  procedure upd_employees(p_employee_id number,
                          p_first_name varchar2 default null,
                          p_last_name varchar2 default null,
                          p_email varchar2 default null,
                          p_phone_number varchar2 default null,
                          p_hire_date date default null,
                          p_job_id varchar2 default null,
                          p_salary number default null,
                          p_commission_pct number default null,
                          p_manager_id number default null,
                          p_department_id number default null)
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

  procedure upd_first_name(p_employee_id number,
                           p_first_name varchar2)
  is
  begin

    update employees e
       set e.first_name = p_first_name
     where e.employee_id = p_employee_id;

  exception
    when others then
      raise_application_error(-20001, dbms_utility.format_error_stack);
  end upd_first_name;

  procedure upd_last_name(p_employee_id number,
                          p_last_name varchar2)
  is
  begin

    update employees e
       set e.last_name = p_last_name
     where e.employee_id = p_employee_id;

  exception
    when others then
      raise_application_error(-20001, dbms_utility.format_error_stack);
  end upd_last_name;

  procedure upd_email(p_employee_id number,
                      p_email varchar2)
  is
  begin

    update employees e
       set e.email = p_email
     where e.employee_id = p_employee_id;

  exception
    when others then
      raise_application_error(-20001, dbms_utility.format_error_stack);
  end upd_email;

  procedure upd_phone_number(p_employee_id number,
                             p_phone_number varchar2)
  is
  begin

    update employees e
       set e.phone_number = p_phone_number
     where e.employee_id = p_employee_id;

  exception
    when others then
      raise_application_error(-20001, dbms_utility.format_error_stack);
  end upd_phone_number;

  procedure upd_hire_date(p_employee_id number,
                          p_hire_date date)
  is
  begin

    update employees e
       set e.hire_date = p_hire_date
     where e.employee_id = p_employee_id;

  exception
    when others then
      raise_application_error(-20001, dbms_utility.format_error_stack);
  end upd_hire_date;

  procedure upd_job_id(p_employee_id number,
                       p_job_id varchar2)
  is
  begin

    update employees e
       set e.job_id = p_job_id
     where e.employee_id = p_employee_id;

  exception
    when others then
      raise_application_error(-20001, dbms_utility.format_error_stack);
  end upd_job_id;

  procedure upd_salary(p_employee_id number,
                       p_salary number)
  is
  begin

    update employees e
       set e.salary = p_salary
     where e.employee_id = p_employee_id;

  exception
    when others then
      raise_application_error(-20001, dbms_utility.format_error_stack);
  end upd_salary;

  procedure upd_commission_pct(p_employee_id number,
                               p_commission_pct number)
  is
  begin

    update employees e
       set e.commission_pct = p_commission_pct
     where e.employee_id = p_employee_id;

  exception
    when others then
      raise_application_error(-20001, dbms_utility.format_error_stack);
  end upd_commission_pct;

  procedure upd_manager_id(p_employee_id number,
                           p_manager_id number)
  is
  begin

    update employees e
       set e.manager_id = p_manager_id
     where e.employee_id = p_employee_id;

  exception
    when others then
      raise_application_error(-20001, dbms_utility.format_error_stack);
  end upd_manager_id;

  procedure upd_department_id(p_employee_id number,
                              p_department_id number)
  is
  begin

    update employees e
       set e.department_id = p_department_id
     where e.employee_id = p_employee_id;

  exception
    when others then
      raise_application_error(-20001, dbms_utility.format_error_stack);
  end upd_department_id;

  function exists_employees(p_employee_id number)
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

  function get_first_name(p_employee_id number)
  return varchar2
  is
    l_result varchar2(20);
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

  function get_last_name(p_employee_id number)
  return varchar2
  is
    l_result varchar2(25);
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

  function get_email(p_employee_id number)
  return varchar2
  is
    l_result varchar2(25);
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

  function get_phone_number(p_employee_id number)
  return varchar2
  is
    l_result varchar2(20);
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

  function get_hire_date(p_employee_id number)
  return date
  is
    l_result date;
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

  function get_job_id(p_employee_id number)
  return varchar2
  is
    l_result varchar2(10);
  begin

    select e.job_id
      into l_result
      from employees e
     where e.employee_id = p_employee_id;

    return l_result;

  exception
    when no_data_found then
      return null;
    when others then
      raise_application_error(-20001, dbms_utility.format_error_stack);
  end get_job_id;

  function get_salary(p_employee_id number)
  return number
  is
    l_result number(8, 2);
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

  function get_commission_pct(p_employee_id number)
  return number
  is
    l_result number(2, 2);
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

  function get_manager_id(p_employee_id number)
  return number
  is
    l_result number(6, 0);
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

  function get_department_id(p_employee_id number)
  return number
  is
    l_result number(4, 0);
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

end employees_pkg;
/