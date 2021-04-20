<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>ASI_KOR_VisitConcatYearMonthOwner</fullName>
        <field>ASI_KOR_Sys_YearAndMonthAndOwner__c</field>
        <formula>ASI_KOR_Year__c &amp; &apos;_&apos; &amp; TEXT( ASI_KOR_Month__c ) &amp; &apos;_&apos; &amp; OwnerId</formula>
        <name>ASI_KOR_VisitConcatYearMonthOwner</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_KOR_Visitation_Plan_Change_RecordTyp</fullName>
        <field>RecordTypeId</field>
        <lookupValue>ASI_KOR_Visitation_Plan_Locked</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>ASI KOR Visitation Plan Change RecordTyp</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>ASI KOR Lock Visitation Plan</fullName>
        <actions>
            <name>ASI_KOR_Visitation_Plan_Change_RecordTyp</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_KOR_Visitation_Plan__c.ASI_KOR_Confirmed__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Changes the Visitation Plan object record type to &quot;Locked&quot; when the Confirmed field is set to checked</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ASI_KOR_VisitCheckDuplicateYearMonthOwner</fullName>
        <actions>
            <name>ASI_KOR_VisitConcatYearMonthOwner</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISNEW() || ISCHANGED( ASI_KOR_Year__c ) || ISCHANGED( ASI_KOR_Month__c ) || ISCHANGED( OwnerId ) || ISCHANGED( ASI_KOR_Sys_YearAndMonthAndOwner__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
