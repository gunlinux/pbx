UPDATE `freepbx_settings` SET
`keyword` = 'ASTMANAGERHOST',
`value` = 'asterisk',
`name` = 'Asterisk Manager Host',
`level` = '2',
`description` = 'Hostname for the Asterisk Manager',
`type` = 'text',
`options` = '',
`defaultval` = 'localhost',
`readonly` = '1',
`hidden` = '0',
`category` = 'Asterisk Manager',
`module` = '',
`emptyok` = '0',
`sortorder` = '0'
WHERE `keyword` = 'ASTMANAGERHOST' AND `keyword` = 'ASTMANAGERHOST' COLLATE utf8mb4_bin;

(0.067 s)
