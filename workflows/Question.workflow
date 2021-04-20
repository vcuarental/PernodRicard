<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>NewQuestionPostedInAnswer</fullName>
        <description>NewQuestionPostedInAnswer</description>
        <protected>false</protected>
        <recipients>
            <recipient>chatter@pernod-ricard.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Answer_New_Item_posted_alert</template>
    </alerts>
    <rules>
        <fullName>NewQuestionInAnswers</fullName>
        <actions>
            <name>NewQuestionPostedInAnswer</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>User.IsActive</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>WorkFlow triggered when a new question is raised in answers tab</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
