-- Create table for shavit mapzones
--
CREATE TABLE `mapzones` (
  `id` int(11) AUTO_INCREMENT PRIMARY KEY,
  `map` varchar(255) NOT NULL,
  `type` int(11) DEFAULT NULL,
  `corner1_x` float DEFAULT NULL,
  `corner1_y` float DEFAULT NULL,
  `corner1_z` float DEFAULT NULL,
  `corner2_x` float DEFAULT NULL,
  `corner2_y` float DEFAULT NULL,
  `corner2_z` float DEFAULT NULL,
  `destination_x` float NOT NULL DEFAULT '0',
  `destination_y` float NOT NULL DEFAULT '0',
  `destination_z` float NOT NULL DEFAULT '0',
  `track` int(11) NOT NULL DEFAULT '0',
  `flags` int(11) NOT NULL DEFAULT '0',
  `data` int(11) NOT NULL DEFAULT '0',
  `hookname` char(128) CHARACTER SET utf8mb4 DEFAULT 'NONE',
  `form` tinyint(4) DEFAULT NULL,
  `target` varchar(63) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


-- Insert data from ck_zones to mapzones that doesn't need special attention
--
INSERT INTO mapzones (map, type, data, corner1_x, corner1_y, corner1_z, corner2_x, corner2_y, corner2_z, track, hookname, target) 
SELECT mapname, zonetype, zonetypeid, pointa_x, pointa_y, pointa_z, pointb_x, pointb_y, pointb_z, zonegroup, hookname, targetname
FROM ck_zones WHERE `pointa_x` <> 0 AND `pointa_y` <> 0 AND `pointa_z` <> 0 AND `pointb_x` <> 0 AND `pointb_y` <> 0 AND `pointb_z` <> 0;

-- Add custom spawns
--
/*UPDATE mapzones AS mz
INNER JOIN ck_spawnlocations AS cksl ON mz.map = cksl.mapname AND mz.type = 1 AND mz.track = 1
SET 
    mz.destination_x = cksl.pos_x,
    mz.destination_y = cksl.pos_y,
    mz.destination_z = cksl.pos_z
WHERE 
    cksl.zonegroup = 0 AND 
    cksl.stage = 1 AND 
    cksl.teleside = 0;*/


-- Convert zonetypes to shavit
--
UPDATE mapzones 
SET `type` = CASE `type`
    WHEN 1 THEN 0    /* startzones */
    WHEN 2 THEN 1    /* endzones */
    WHEN 3 THEN 12   /* stages */
    WHEN 4 THEN 5    /* Checkpoints (freestyle/ignored for now)*/
    WHEN 5 THEN 0    /* startzone fixes */
    WHEN 6 THEN 3    /* tele-to-start set to glitch teleport */
    WHEN 7 THEN 5    /* tele fix of some sort? */
    ELSE `type`
END;

-- Fix Stage Numbering
--
UPDATE mapzones SET data = data+2 WHERE type = 12;

-- Fix minimum zone height
-- Arbitrary preferred value 
SET @set_value := 300.0; 

UPDATE mapzones
SET 
    corner1_z = CASE 
        WHEN (corner2_z - corner1_z) < 0 THEN corner1_z + (@set_value - (corner2_z - corner1_z))
        ELSE corner1_z
        END,
    corner2_z = CASE 
        WHEN (corner2_z - corner1_z) >= 0 THEN corner2_z + (@set_value - (corner2_z - corner1_z))
        ELSE corner2_z
        END
WHERE `type` = 0 AND `track` IN (0, 1);