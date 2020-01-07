# PL-SQL-PackageGenerator
A package for generating new PL / SQL packages with basic functions and procedures for working with a table.

Can save time writing hundreds of lines of code for new or existing tables.

## Requirements
Oracle RDBMS 11g and above

##Install
1. This is a script in an anonymous block without the need to compile the package in the database: pkg_gen__anon_block.sql. 
Make the calls you need with the necessary parameters in the begin block .. end and execute it.

2. Package: pkg_gen__package.sql. Complile package in database schema. New Package PKG_GEN will be created in database schema. 

## How to use
Procedure and Function descriptions with input and output parameters are located in package definition script.

Additional script with examples is available in "examples" directory (in development)

## How it works
The application can be use to create package with lot of simple functions and procedures for working with one table.
Functions and procedures can also be created separately to use then in existing packages or other programm units.
After code generation edit code as you need (add transaction control, documentation, etc), compile and use it.

Code generation works for tables with ID field (physical PK or defined logically via parameter).
Generated programs implement the basic functionality of working with a table: insert, update, delete and select data from table.

## Code Generation Features
### Generating programms
- procedure that insert data into table
- function that insert data into table and returns ID of created row
- procedure that delete row from the table by PK 
- procedure that update each column (except PK) by PK 
A null value in procedure parametrs does not overwrite non-null data in a column.
- procedures that update one column value by PK (for each column except PK)
- function that checks if record exist in a table by PK
- functions that select one column value by PK (for each column except PK). 
No_data_found exception can raise error or return null by custom setting 

### other
- Ability to disable code generation for selected types of functions/procedures
- Ability to disable code generation for selected columns of update and select one column functions/procedures
- Ability to generate code only for choosed functions/procedures without generation package
- Add documentation template for package, function or procedure
- In documentation templates available snippes for author, list parameters, name of generated programm and custom needs
- Virtual columns are not used in insert/update procedures
- Parameters for insert value into nullable columns are null by default 
- Choose using declartion with %type attribute or explicit column data type for parametrs
- Add custom prefix and suffix to variables and parameters to meet different coding standards
- Custom variable/parameter/programm name length limit
- A huge volume of generated code (more than 32K) is displayed correctly
