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
  'game/main/main.tscn',
  'game/main/main.gd',
  'game/player/player.tscn',
  'game/player/player.gd',
  'game/pets/pet_companion.tscn',
  'game/pets/pet_companion.gd',
  'game/enemies/zombie.tscn',
  'game/enemies/zombie.gd',
  'game/projectiles/bullet.tscn',
  'game/projectiles/bullet.gd',
  'game/ui/hud.tscn',
  'game/ui/hud.gd',
  'tests/player-crouch.gd',
  'tests/production-animations.gd',
  'tests/gameplay-smoke.gd'
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
  const matches = content.matchAll(/res:\/\/([^"')\s]+)/g);
  for (const match of matches) {
    const referenced = path.join(root, match[1]);
    try {
      await access(referenced);
    } catch {
      errors.push(`${path.relative(root, file)} references missing ${match[0]}`);
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

