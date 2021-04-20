<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>EUR_GB_Champagne_Menu_Notification</fullName>
        <description>EUR_GB Champagne Menu Notification</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>EUR_CRM_GB_Email_Template/EUR_CRM_GB_Menu_Champagne</template>
    </alerts>
    <alerts>
        <fullName>EUR_GB_Drinks_Menu_Notification</fullName>
        <description>GB Drinks Menu Notification</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>EUR_CRM_GB_Email_Template/EUR_CRM_GB_Menu_Drinks</template>
    </alerts>
    <rules>
        <fullName>EUR_GB_Champagne_Menu_Reminder</fullName>
        <active>true</active>
        <booleanFilter>1 AND 2</booleanFilter>
        <criteriaItems>
            <field>EUR_CRM_Menu_Feature__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Champagne Menu</value>
        </criteriaItems>
        <criteriaItems>
            <field>EUR_CRM_Menu_Feature__c.EUR_CRM_Menu_Type__c</field>
            <operation>equals</operation>
            <value>Main</value>
        </criteriaItems>
        <description>An email notification should be sent out to the SR 60 days before the Main Drinks/Cocktails Menu ends, to remind him to visit the outlet to negotiate a new menu.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>EUR_GB_Champagne_Menu_Notification</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>EUR_CRM_Menu_Feature__c.EUR_CRM_End_Date__c</offsetFromField>
            <timeLength>-60</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>EUR_GB_Drinks_Menu_Reminder</fullName>
        <active>true</active>
        <booleanFilter>1 AND 2</booleanFilter>
        <criteriaItems>
            <field>EUR_CRM_Menu_Feature__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Drinks Menu</value>
        </criteriaItems>
        <criteriaItems>
            <field>EUR_CRM_Menu_Feature__c.EUR_CRM_Menu_Type__c</field>
            <operation>equals</operation>
            <value>Main</value>
        </criteriaItems>
        <description>An email notification should be sent out to the SR 60 days before the Main Drinks/Cocktails Menu ends, to remind him to visit the outlet to negotiate a new menu.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>EUR_GB_Drinks_Menu_Notification</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>EUR_CRM_Menu_Feature__c.EUR_CRM_End_Date__c</offsetFromField>
            <timeLength>-60</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>
