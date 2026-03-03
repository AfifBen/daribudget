import React from 'react';

export default function App() {
  return (
    <div className="min-h-screen bg-gray-50">
      <header className="px-6 py-4 bg-white border-b">
        <h1 className="text-2xl font-bold">DariBudget</h1>
        <p className="text-sm text-gray-500">Budget familial intelligent</p>
      </header>
      <main className="p-6">
        <div className="bg-white p-6 rounded-lg shadow-sm">
          <h2 className="text-lg font-semibold mb-2">Dashboard</h2>
          <p className="text-gray-600">UI à venir (dépenses, budgets, courses).</p>
        </div>
      </main>
    </div>
  );
}
