import React, { useState } from 'react';

const Tab = ({ label, active, onClick }) => (
  <button
    onClick={onClick}
    className={`px-4 py-2 rounded-lg text-sm font-medium ${
      active ? 'bg-blue-600 text-white' : 'bg-gray-100 text-gray-700'
    }`}
  >
    {label}
  </button>
);

export default function App() {
  const [active, setActive] = useState('dashboard');

  return (
    <div className="min-h-screen bg-gray-50">
      <header className="px-6 py-4 bg-white border-b">
        <h1 className="text-2xl font-bold">DariBudget</h1>
        <p className="text-sm text-gray-500">Budget familial intelligent</p>
      </header>

      <main className="p-6 space-y-6">
        <div className="flex gap-2 flex-wrap">
          <Tab label="Dashboard" active={active==='dashboard'} onClick={()=>setActive('dashboard')} />
          <Tab label="Dépenses" active={active==='expenses'} onClick={()=>setActive('expenses')} />
          <Tab label="Budgets" active={active==='budgets'} onClick={()=>setActive('budgets')} />
          <Tab label="Courses" active={active==='shopping'} onClick={()=>setActive('shopping')} />
        </div>

        {active === 'dashboard' && (
          <div className="bg-white p-6 rounded-lg shadow-sm">
            <h2 className="text-lg font-semibold mb-4">Résumé Mensuel</h2>
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
              <div className="p-4 bg-gray-100 rounded">Total dépenses: 0 DA</div>
              <div className="p-4 bg-gray-100 rounded">Budget restant: 0 DA</div>
              <div className="p-4 bg-gray-100 rounded">Épargne: 0 DA</div>
            </div>
          </div>
        )}

        {active === 'expenses' && (
          <div className="bg-white p-6 rounded-lg shadow-sm">
            <h2 className="text-lg font-semibold mb-4">Dépenses</h2>
            <button className="px-4 py-2 bg-blue-600 text-white rounded">Ajouter dépense</button>
            <div className="mt-4 text-gray-500">Liste des dépenses (placeholder)</div>
          </div>
        )}

        {active === 'budgets' && (
          <div className="bg-white p-6 rounded-lg shadow-sm">
            <h2 className="text-lg font-semibold mb-4">Budgets</h2>
            <button className="px-4 py-2 bg-blue-600 text-white rounded">Ajouter budget</button>
            <div className="mt-4 text-gray-500">Liste des budgets (placeholder)</div>
          </div>
        )}

        {active === 'shopping' && (
          <div className="bg-white p-6 rounded-lg shadow-sm">
            <h2 className="text-lg font-semibold mb-4">Liste de courses</h2>
            <button className="px-4 py-2 bg-blue-600 text-white rounded">Ajouter item</button>
            <div className="mt-4 text-gray-500">Liste des items (placeholder)</div>
          </div>
        )}
      </main>
    </div>
  );
}
