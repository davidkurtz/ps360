# PS360
PeopleSoft: Configuration and Metrics Utility

ps360 is a "free to use" tool that collects information about a PeopleSoft system.

Steps
~~~~~
1. Unzip ps360.zip, navigate to the root ps360 directory, and connect as the PeopleSoft owner ID
   (by default SYSADM)

   $ unzip ps360.zip
   $ cd ps360
   $ sqlplus SYSADM/<sysadm password>@<database name>
   SQL> @ps360
   
2. Unzip output ps360_<dbname>_YYYYMMDD_HH24MI.zip into a directory on your PC

3. Review main html file ps360_<dbname>_0_index.html in 

****************************************************************************************

Notes
~~~~~
1. The script can be run as another database user so long as that user has read access to
   the PeopleSoft owning schema, the table PS.PSDBOWNER and select_catalog_role
2. If you need to change default "working hours" between 7:30AM and 7:30PM modify 
   variables set in file ps_0config.sql (back it up first).
   
****************************************************************************************
   
    ps360 - PeopleSoft 360-degree View
    Copyright (C) 2016  David Kurtz

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

****************************************************************************************
