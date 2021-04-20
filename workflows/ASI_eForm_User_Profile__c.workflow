<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>ASI_eForm_HK_User_Expiry_Email_Alert</fullName>
        <description>ASI eForm User Expiry Email Alert (HK)</description>
        <protected>false</protected>
        <recipients>
            <field>ASI_eForm_Ownership_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>pra.sfdcitsupport@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ASI_eForm_Email_Templates/ASI_eForm_HK_UIDR_NET_Ey_Ny_Email_Tmpt</template>
    </alerts>
    <fieldUpdates>
        <fullName>ASI_eForm_Set_User_Name</fullName>
        <field>Name</field>
        <formula>ASI_eForm_First_Name__c  &amp; &quot; &quot; &amp;  ASI_eForm_Last_Name__c</formula>
        <name>ASI eForm Set User Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>ASI_eForm_Concat_User_Name</fullName>
        <actions>
            <name>ASI_eForm_Set_User_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_eForm_User_Profile__c.ASI_eForm_Last_Name__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ASI_eForm_HK_NET_Expiry_Notification</fullName>
        <active>true</active>
        <criteriaItems>
            <field>ASI_eForm_User_Profile__c.ASI_eForm_Service_Period_To__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>ASI_eForm_HK_User_Expiry_Email_Alert</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>ASI_eForm_User_Profile__c.ASI_eForm_Service_Period_To__c</offsetFromField>
            <timeLength>-30</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>
