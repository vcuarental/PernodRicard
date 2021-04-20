<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>BMCServiceDesk__Notify_problem_owner_when_change_request_linked_to_problem_is_closed</fullName>
        <description>Notify problem owner when change request linked to problem is closed</description>
        <protected>false</protected>
        <recipients>
            <field>BMCServiceDesk__FKProblem_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMCServiceDesk__Change_Request_of_Problem_is_closed</template>
    </alerts>
    <fieldUpdates>
        <fullName>AME_Set_Problem_Number_on_Change</fullName>
        <field>BMC_RF_Problem_Text__c</field>
        <formula>BMCServiceDesk__FKProblem__r.Name</formula>
        <name>AME Set Problem Number on Change</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
        <targetObject>BMCServiceDesk__FKChange__c</targetObject>
    </fieldUpdates>
    <rules>
        <fullName>AME Set Problem Number on Change</fullName>
        <actions>
            <name>AME_Set_Problem_Number_on_Change</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>BMCServiceDesk__Change_Request__c.BMC_RF_Problem_Text__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>BMCServiceDesk__Notify problem owner when change request linked to problem is closed</fullName>
        <actions>
            <name>BMCServiceDesk__Notify_problem_owner_when_change_request_linked_to_problem_is_closed</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>Notify problem owner when change request linked to problem is closed</description>
        <formula>AND( NOT( BMCServiceDesk__FKChange__r.BMCServiceDesk__State__c),   Not(ISCHANGED( BMCServiceDesk__FKProblem_Owner__c ))  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
