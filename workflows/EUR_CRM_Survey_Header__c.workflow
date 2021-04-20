<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>EUR_BG_Active_Field_False</fullName>
        <description>On BG Survey Headers, the field Active can be set to false once the Valid Until date has passed.</description>
        <field>EUR_CRM_Active__c</field>
        <literalValue>0</literalValue>
        <name>EUR BG Active Field False</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EUR_CRM_BG_Update_Reoccuring_Field</fullName>
        <description>When EUR_CRM_Survey_Header__c.EUR_CRM_Valid_Until__c &lt; Today,
EUR_CRM_Survey_Header__c.EUR_CRM_Reoccuring__c = FALSE</description>
        <field>EUR_CRM_Reoccuring__c</field>
        <literalValue>0</literalValue>
        <name>EUR BG Update Reoccuring Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>EUR BG Pre-populate Reoccuring field in Survey Header %28EU%29</fullName>
        <actions>
            <name>EUR_CRM_BG_Update_Reoccuring_Field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>(1 OR 2) AND 3</booleanFilter>
        <criteriaItems>
            <field>EUR_CRM_Survey_Header__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>EUR BG ON Trade Survey Header</value>
        </criteriaItems>
        <criteriaItems>
            <field>EUR_CRM_Survey_Header__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>EUR BG OFF Trade Survey Header</value>
        </criteriaItems>
        <criteriaItems>
            <field>EUR_CRM_Survey_Header__c.EUR_CRM_Valid_Until__c</field>
            <operation>lessThan</operation>
            <value>TODAY</value>
        </criteriaItems>
        <description>When EUR_CRM_Survey_Header__c.EUR_CRM_Valid_Until__c &lt; Today,
EUR_CRM_Survey_Header__c.EUR_CRM_Reoccuring__c = FALSE</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>EUR BG Survey Header Deactivate Active field</fullName>
        <active>true</active>
        <booleanFilter>1 AND (2 OR 3)</booleanFilter>
        <criteriaItems>
            <field>EUR_CRM_Survey_Header__c.EUR_CRM_Active__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>EUR_CRM_Survey_Header__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>EUR BG OFF Trade Survey Header</value>
        </criteriaItems>
        <criteriaItems>
            <field>EUR_CRM_Survey_Header__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>EUR BG ON Trade Survey Header</value>
        </criteriaItems>
        <description>Active field on the Survey Header can be deactivated once the valid until date has passed.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>EUR_BG_Active_Field_False</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>EUR_CRM_Survey_Header__c.EUR_CRM_Valid_Until__c</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>
