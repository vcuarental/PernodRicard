<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>LAT_BR_Coleta_Finalizada</fullName>
        <description>LAT BR Coleta Finalizada</description>
        <protected>false</protected>
        <recipients>
            <recipient>LAT_SellOutCollectNotifications</recipient>
            <type>group</type>
        </recipients>
        <recipients>
            <field>LastModifiedById</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>LAT_Templates/LAT_BR_Finalizou_Coleta</template>
    </alerts>
</Workflow>
