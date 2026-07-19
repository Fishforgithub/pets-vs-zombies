import { access, readFile, readdir } from 'node:fs/promises';
import path from 'node:path';
import process from 'node:process';

const root = path.resolve(import.meta.dirname, '..');
const requiredFiles = [
  'project.godot',
  'AGENTS.md',
  'docs/GAME_DESIGN.md',
  'docs/ART_DIRECTION.md',
  'docs/ASSET_MIGRATION.md',
  'docs/ART_ASSET_MANIFEST.md',
  'docs/ART_REQUEST_QUEUE.md',
  'docs/STAGE_1_PLAN.md',
  'docs/STAGE_2_ART_PLAN.md',
  'assets/props/stage1/street_props.png',
  'assets/props/stage1/crate_break_sheet.png',
  'assets/items/pickups.png',
  'assets/vfx/combat_effects.png',
  'assets/vfx/foreman_shockwave.png',
  'assets/ui/stage1/boss_health_frame.png',
  'assets/enemies/umbrella_zombie/idle.png',
  'assets/enemies/umbrella_zombie/walk_sheet.png',
  'assets/enemies/umbrella_zombie/action_sheet.png',
  'docs/WEB_DEPLOYMENT.md',
  'export_presets.cfg',
  'wrangler.jsonc',
  'deploy/cloudflare-worker.js',
  'game/main/main.tscn',
  'game/main/main.gd',
  'game/bosses/foreman_boss.tscn',
  'game/bosses/foreman_boss.gd',
  'game/bosses/foreman_shockwave.tscn',
  'game/bosses/foreman_shockwave.gd',
  'game/stages/wave_director.tscn',
  'game/stages/wave_director.gd',
  'game/player/player.tscn',
  'game/player/player.gd',
  'game/progression/run_progression.tscn',
  'game/progression/run_progression.gd',
  'game/progression/weapon_data.gd',
  'game/progression/pet_skill_data.gd',
  'game/data/weapons/starter_pistol.tres',
  'game/data/pet_skills/energy_bolt.tres',
  'game/pets/pet_companion.tscn',
  'game/pets/pet_companion.gd',
  'game/enemies/zombie.tscn',
  'game/enemies/zombie.gd',
  'game/enemies/wave_enemy.gd',
  'game/enemies/stage2/zombie_crow.tscn',
  'game/enemies/stage2/zombie_crow.gd',
  'game/enemies/stage2/zombie_nurse.tscn',
  'game/enemies/stage2/zombie_nurse.gd',
  'game/enemies/stage2/zombie_doctor.tscn',
  'game/enemies/stage2/zombie_doctor.gd',
  'game/enemies/stage2/wheelchair_zombie.tscn',
  'game/enemies/stage2/wheelchair_zombie.gd',
  'game/projectiles/bullet.tscn',
  'game/projectiles/bullet.gd',
  'game/projectiles/bandage_projectile.tscn',
  'game/projectiles/bandage_projectile.gd',
  'game/vfx/stage2_hospital_effect.tscn',
  'game/vfx/stage2_hospital_effect.gd',
  'game/vfx/combat_hit_effect.tscn',
  'game/vfx/combat_hit_effect.gd',
  'game/ui/hud.tscn',
  'game/ui/hud.gd',
  'game/ui/stage_result.tscn',
  'game/ui/stage_result.gd',
  'tests/player-crouch.gd',
  'tests/production-animations.gd',
  'tests/gameplay-smoke.gd',
  'tests/wave-director.gd',
  'tests/foreman-boss.gd',
  'tests/progression.gd',
  'tests/stage-result.gd',
  'tests/stage2-assets.gd',
  'tests/zombie-crow.gd',
  'tests/zombie-nurse.gd',
  'tests/zombie-doctor.gd',
  'tests/stage2-effects.gd',
  'tests/wheelchair-zombie.gd',
  'tests/combat-feedback.gd'
];

const errors = [];

for (const relative of requiredFiles) {
  try {
    await access(path.join(root, relative));
  } catch {
    errors.push(`Missing required file: ${relative}`);
  }
}

const project = await readFile(path.join(root, 'project.godot'), 'utf8');
if (!project.includes('run/main_scene="res://game/main/main.tscn"')) {
  errors.push('project.godot does not point to the expected main scene.');
}

const exportPresets = await readFile(path.join(root, 'export_presets.cfg'), 'utf8');
if (!exportPresets.includes('platform="Web"') || !exportPresets.includes('variant/thread_support=false') || !exportPresets.includes('build/*')) {
  errors.push('export_presets.cfg must define a single-threaded Web export.');
}
const textExtensions = new Set(['.gd', '.tscn', '.godot', '.md', '.json', '.mjs']);
async function walk(directory) {
  const entries = await readdir(directory, { withFileTypes: true });
  const files = [];
  for (const entry of entries) {
    if (entry.name === '.git' || entry.name === '.godot') continue;
    const absolute = path.join(directory, entry.name);
    if (entry.isDirectory()) files.push(...await walk(absolute));
    else files.push(absolute);
  }
  return files;
}

for (const file of await walk(root)) {
  if (!textExtensions.has(path.extname(file))) continue;
  const content = await readFile(file, 'utf8');
  const relativeFile = path.relative(root, file).replaceAll('\\', '/');
  if (relativeFile !== 'docs/ART_REQUEST_QUEUE.md') {
    const matches = content.matchAll(/res:\/\/([^"')\s]+)/g);
    for (const match of matches) {
      const referenced = path.join(root, match[1]);
      try {
        await access(referenced);
      } catch {
        errors.push(`${path.relative(root, file)} references missing ${match[0]}`);
      }
    }
  }
  if (/OPENAI_API_KEY\s*=\s*[^\s<]/.test(content)) {
    errors.push(`${path.relative(root, file)} appears to contain an API key assignment.`);
  }
}

if (errors.length) {
  console.error(errors.map((error) => `- ${error}`).join('\n'));
  process.exitCode = 1;
} else {
  console.log(`Project structure OK (${requiredFiles.length} required files checked).`);
}
