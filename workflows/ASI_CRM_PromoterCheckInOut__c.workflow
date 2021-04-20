<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>ASI_CRM_VN_Update_Submit_Date_Time_Zone</fullName>
        <description>Update the submit date time by vn time zone</description>
        <field>ASI_CRM_SubmitDateTime__c</field>
        <formula>ASI_CRM_SubmitDateTime__c - 1/24</formula>
        <name>ASI CRM VN Update Submit Date Time Zone</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>ASI CRM VN Update by VN Time Zone</fullName>
        <actions>
            <name>ASI_CRM_VN_Update_Submit_Date_Time_Zone</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_CRM_PromoterCheckInOut__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>VN Promoter Check In/Out</value>
        </criteriaItems>
        <description>If the record type is VN, update the sumbit dat time by VN time zone</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
