#!/usr/bin/env node

/**
 * Database Connection Test Script for Neon PostgreSQL
 * 
 * This script tests various connection string formats to identify
 * the correct configuration for Railway deployment.
 */

const { Client } = require('pg');

// Test connection strings based on official Neon Railway documentation
const connectionStrings = [
  // Official Neon Railway format (from documentation)
  'postgresql://neondb_owner:npg_7Y1srBETQcjk@ep-wispy-union-a8ochsuh-pooler.eastus2.azure.neon.tech:5432/neondb?sslmode=require',

  // Without pooler (direct connection)
  'postgresql://neondb_owner:npg_7Y1srBETQcjk@ep-wispy-union-a8ochsuh.eastus2.azure.neon.tech:5432/neondb?sslmode=require',

  // With minimal SSL
  'postgresql://neondb_owner:npg_7Y1srBETQcjk@ep-wispy-union-a8ochsuh-pooler.eastus2.azure.neon.tech:5432/neondb',
];

async function testConnection(connectionString, index) {
  console.log(`\n🔍 Testing Connection ${index + 1}:`);
  console.log(`URL: ${connectionString.replace(/:[^:@]*@/, ':****@')}`);
  
  const client = new Client({
    connectionString,
    ssl: {
      rejectUnauthorized: false
    },
    connectionTimeoutMillis: 10000,
  });

  try {
    console.log('⏳ Connecting...');
    await client.connect();
    
    console.log('✅ Connection successful!');
    
    // Test a simple query
    const result = await client.query('SELECT version(), current_database(), current_user');
    console.log('📊 Database Info:');
    console.log(`   Version: ${result.rows[0].version.split(' ').slice(0, 2).join(' ')}`);
    console.log(`   Database: ${result.rows[0].current_database}`);
    console.log(`   User: ${result.rows[0].current_user}`);
    
    // Test table access
    try {
      const tableResult = await client.query(`
        SELECT table_name 
        FROM information_schema.tables 
        WHERE table_schema = 'public' 
        LIMIT 5
      `);
      console.log(`📋 Found ${tableResult.rows.length} tables in public schema`);
    } catch (tableError) {
      console.log('⚠️  Could not query tables:', tableError.message);
    }
    
    await client.end();
    return true;
    
  } catch (error) {
    console.log('❌ Connection failed:');
    console.log(`   Error: ${error.message}`);
    console.log(`   Code: ${error.code || 'N/A'}`);
    
    try {
      await client.end();
    } catch (endError) {
      // Ignore cleanup errors
    }
    
    return false;
  }
}

async function main() {
  console.log('🚀 Neon PostgreSQL Connection Test');
  console.log('=====================================');
  
  let successCount = 0;
  
  for (let i = 0; i < connectionStrings.length; i++) {
    const success = await testConnection(connectionStrings[i], i);
    if (success) {
      successCount++;
      console.log(`\n✨ SUCCESS! Use this connection string for Railway:`);
      console.log(`DATABASE_URL=${connectionStrings[i]}`);
      break; // Stop on first success
    }
    
    // Wait between attempts
    if (i < connectionStrings.length - 1) {
      console.log('\n⏱️  Waiting 2 seconds before next attempt...');
      await new Promise(resolve => setTimeout(resolve, 2000));
    }
  }
  
  console.log('\n📈 Test Summary:');
  console.log(`   Successful connections: ${successCount}/${connectionStrings.length}`);
  
  if (successCount === 0) {
    console.log('\n🚨 All connection attempts failed!');
    console.log('\n🔧 Troubleshooting steps:');
    console.log('   1. Verify Neon database is active');
    console.log('   2. Check if password has changed');
    console.log('   3. Ensure IP is not blocked');
    console.log('   4. Try generating new connection string from Neon console');
    process.exit(1);
  } else {
    console.log('\n🎉 Connection test completed successfully!');
    process.exit(0);
  }
}

// Handle unhandled promise rejections
process.on('unhandledRejection', (reason, promise) => {
  console.error('Unhandled Rejection at:', promise, 'reason:', reason);
  process.exit(1);
});

// Run the test
main().catch(console.error);
