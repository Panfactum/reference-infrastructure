#!/usr/bin/env bun

import { promises as fs } from "fs";
import * as path from "path";
import * as sqlite3 from "sqlite3";

// Configuration
const DATA_ROOT = "/home/uptown/Projects/panfactum/reference-infrastructure/services/bi/data";
const DB_PATH = "/home/uptown/Projects/panfactum/reference-infrastructure/services/bi/bi.sqlite";

// Main