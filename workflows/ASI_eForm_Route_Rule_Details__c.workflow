<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>ASI_eForm_CN_Set_Note</fullName>
        <field>ASI_eForm_Note__c</field>
        <formula>IF(ASI_eForm_Preview_Approver__c, &quot;Preview Approver&quot;, 

IF( ASI_eForm_Route_Type__r.ASI_eForm_Sys_Approver_Count__c = 0, &quot;High-Level Authorizer&quot;, IF( ASI_eForm_Route_Type__r.ASI_eForm_Sys_Approver_Count__c = 1, &quot;Further Authorizer&quot;, &quot;CIO Approver&quot;)) 
)</formula>
        <name>ASI eForm Set Note (CN)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_eForm_HK_Set_Note</fullName>
        <field>ASI_eForm_Note__c</field>
        <formula>IF(ASI_eForm_Preview_Approver__c, &quot;Preview Approver&quot;, 

CASE(ASI_eForm_Route_Type__r.ASI_eForm_Form_Type__c, 
&quot;IT Change Request&quot;,  IF( ASI_eForm_Route_Type__r.ASI_eForm_Sys_Approver_Count__c = 0, &quot;High-Level Authorizer&quot;, IF( ASI_eForm_Route_Type__r.ASI_eForm_Sys_Approver_Count__c = 1, &quot;Further Authorizer&quot;, &quot;CIO Approver&quot;)) , 
&quot;Procurement &amp; Service Request&quot;,  IF( ISPICKVAL( ASI_eForm_Route_Type__r.ASI_eForm_Form_Record_Type__c , &quot;IT Service Request (HK)&quot;)  , &quot;CIO Approver&quot;,  IF(ASI_eForm_Route_Type__r.ASI_eForm_Sys_Approver_Count__c = 0, &quot;Approver&quot;, IF(ASI_eForm_Route_Type__r.ASI_eForm_Sys_Approver_Count__c = 1, &quot;Finance Approver&quot;, &quot;CIO Approver&quot;) ) ) , 
&quot;User ID Request&quot;, &quot;Approver&quot;,
&quot;Approver&quot;) 

)</formula>
        <name>ASI eForm Set Note (HK)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>ASI_eForm_CN_Approval_Level_Indication</fullName>
        <actions>
            <name>ASI_eForm_CN_Set_Note</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_eForm_Route_Rule_Details__c.Name</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>ASI_eForm_Route_Type__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>ASI eForm Route Type (CN)</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>ASI_eForm_HK_Approval_Level_Indication</fullName>
        <actions>
            <name>ASI_eForm_HK_Set_Note</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_eForm_Route_Rule_Details__c.Name</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>ASI_eForm_Route_Type__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>ASI eForm Route Type (HK)</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
