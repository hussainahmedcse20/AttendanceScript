

---- To update status column (in/out) in timePunchMechineRawDatatEST
UPDATE t1
SET strStatus = CASE
    WHEN (t2.row_num % 2) != 0 THEN 'In'
    ELSE 'Out'
END
FROM saas.timePunchMechineRawDatatEST AS t1
JOIN (
    SELECT
        intPunchUserId,
        dteTime,
        CAST(dteDate AS DATE) AS dteDate,
        ROW_NUMBER() OVER (PARTITION BY intPunchUserId, CAST(dtedate AS DATE) ORDER BY dteTime) AS row_num
    FROM saas.timePunchMechineRawDatatEST
) AS t2 ON t1.intPunchUserId = t2.intPunchUserId AND t1.dteTime = t2.dteTime;

----------------------------- to update numStayOfficeminuites column in table  saas.timeAttendanceDailySummaryTest 
SELECT     punch_in.intPunchUserId AS employee_id, punch_in.dateDay as dateDay,    SUM(DATEDIFF(minute, punch_in.timestamp, punch_out.timestamp)) AS total_stay_minutes	into #testEmployeeFROM (    SELECT intPunchUserId, dtetime AS timestamp , dteDate as dateDay    FROM saas.timePunchMechineRawDatatEST    WHERE strStatus = 'IN') AS punch_inJOIN (    SELECT intPunchUserId, dtetime AS timestamp, dteDate as dateDay    FROM saas.timePunchMechineRawDatatEST    WHERE strStatus = 'OUT') AS punch_outON punch_in.intPunchUserId = punch_out.intPunchUserIdand cast(punch_in.dateDay as date)= cast(punch_out.dateDay as date)GROUP BY punch_in.intPunchUserId, punch_in.dateDay;--select *  from saas.timeAttendanceDailySummaryTest as att--join saas.empEmployeeBasicInfo as emp on att.intEmployeeId = emp.intEmployeeBasicInfoId--join #testEmployee as tmp on tmp.employee_id = emp.strCardNumber and att.dteAttendanceDate= tmp.dateDayupdate att set att.numStayOfficeminuites = tmp.total_stay_minutes  from saas.timeAttendanceDailySummaryTest as attjoin saas.empEmployeeBasicInfo as emp on att.intEmployeeId = emp.intEmployeeBasicInfoIdjoin #testEmployee as tmp on tmp.employee_id = emp.strCardNumber and att.dteAttendanceDate= tmp.dateDayDROP TABLE IF EXISTS #testEmployee;


