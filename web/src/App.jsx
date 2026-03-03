import React, { useEffect, useState } from 'react';
import { getExpenses, createExpense, getBudgets, createBudget, getShopping, createShopping } from './api';

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
  const household_id = 1; // temp

  const [expenses, setExpenses] = useState([]);
  const [budgets, setBudgets] = useState([]);
  const [shopping, setShopping] = useState([]);

  useEffect(() => {
    getExpenses({ household_id }).then(r => setExpenses(r.data.data));
    getBudgets({ household_id, month: '2026-03' }).then(r => setBudgets(r.data.data));
    getShopping({ household_id }).then(r => setShopping(r.data.data));
  }, []);

  const addExpense = async () => {
    const res = await createExpense({ household_id, category_id: 1, amount: 1000, note: 'Test', spent_at: '2026-03-01' });
    setExpenses([res.data.data, ...expenses]);
  };

  const addBudget = async () => {
    const res = await createBudget({ household_id, category_id: 1, amount: 5000, month: '2026-03' });
    setBudgets([res.data.data, ...budgets]);
  };

  const addShopping = async () => {
    const res = await createShopping({ household_id, name: 'Lait', category: 'Alimentaire' });
    setShopping([res.data.data, ...shopping]);
  };

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
              <div className="p-4 bg-gray-100 rounded">Total dépenses: {expenses.reduce((s,e)=>s+Number(e.amount||0),0)} DA</div>
              <div className="p-4 bg-gray-100 rounded">Budgets: {budgets.reduce((s,b)=>s+Number(b.amount||0),0)} DA</div>
              <div className="p-4 bg-gray-100 rounded">Courses: {shopping.length}</div>
            </div>
          </div>
        )}

        {active === 'expenses' && (
          <div className="bg-white p-6 rounded-lg shadow-sm">
            <h2 className="text-lg font-semibold mb-4">Dépenses</h2>
            <button onClick={addExpense} className="px-4 py-2 bg-blue-600 text-white rounded">Ajouter dépense</button>
            <ul className="mt-4 text-gray-600 space-y-2">
              {expenses.map(e => (
                <li key={e.id} className="p-2 bg-gray-50 rounded">{e.note} — {e.amount} DA</li>
              ))}
            </ul>
          </div>
        )}

        {active === 'budgets' && (
          <div className="bg-white p-6 rounded-lg shadow-sm">
            <h2 className="text-lg font-semibold mb-4">Budgets</h2>
            <button onClick={addBudget} className="px-4 py-2 bg-blue-600 text-white rounded">Ajouter budget</button>
            <ul className="mt-4 text-gray-600 space-y-2">
              {budgets.map(b => (
                <li key={b.id} className="p-2 bg-gray-50 rounded">Cat {b.category_id} — {b.amount} DA</li>
              ))}
            </ul>
          </div>
        )}

        {active === 'shopping' && (
          <div className="bg-white p-6 rounded-lg shadow-sm">
            <h2 className="text-lg font-semibold mb-4">Liste de courses</h2>
            <button onClick={addShopping} className="px-4 py-2 bg-blue-600 text-white rounded">Ajouter item</button>
            <ul className="mt-4 text-gray-600 space-y-2">
              {shopping.map(i => (
                <li key={i.id} className="p-2 bg-gray-50 rounded">{i.name}</li>
              ))}
            </ul>
          </div>
        )}
      </main>
    </div>
  );
}
