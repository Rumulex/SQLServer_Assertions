# SQLServer_Assertions

This repository contains t-sql scripts that serve to assert continuity and completeness of data in a repository  hosted on SQL Server, that contains metadata gathered by a data catalog. 

The scripts are meant to be run after performing actions with the data catalog software, that could potentially lead to corruption or loss of data. 

All the scripts use similar  od identical logic and methods to achieve this goal and they mostly differ based on types of metadata they are meant to interact with. Some will be identical except for what particular objects they refer to. 