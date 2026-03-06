import React, { useEffect, useState } from 'react';
import { getExpenses, createExpense, getBudgets, createBudget, getShopping, createShopping } from './api';

const Tab = ({ label, active, onClick }) => (
  <button
    onClick={onClick}
    className={`px-4 py-2 rounded-full text-sm font-medium transition ${
      active ? 'bg-gold-500 text-forest-900 shadow-soft' : 'bg-forest-800/70 text-forest-100'
    }`}
  >
    {label}
  </button>
);

const Card = ({ className = '', children }) => (
  <div className={`bg-forest-800/70 border border-forest-700/60 rounded-2xl p-5 shadow-soft ${className}`}>{children}</div>
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

  const totalExpenses = expenses.reduce((s, e) => s + Number(e.amount || 0), 0);
  const totalBudgets = budgets.reduce((s, b) => s + Number(b.amount || 0), 0);

  return (
    <div className="min-h-screen bg-forest-900 text-white">
      <header className="px-6 py-6 border-b border-forest-800/60">
        <div className="max-w-6xl mx-auto flex flex-col md:flex-row md:items-center md:justify-between gap-4">
          <div>
            <h1 className="text-2xl font-semibold text-gold-400 tracking-wide">DariBudget</h1>
            <p className="text-forest-100/70">Budget familial intelligent</p>
          </div>
          <div className="bg-forest-800/60 border border-forest-700/60 px-4 py-2 rounded-full text-sm text-gold-300">Mars 2026</div>
        </div>
      </header>

      <main className="px-6 py-8">
        <div className="max-w-6xl mx-auto space-y-6">
          <div className="flex flex-wrap gap-2">
            <Tab label="Dashboard" active={active === 'dashboard'} onClick={() => setActive('dashboard')} />
            <Tab label="Dépenses" active={active === 'expenses'} onClick={() => setActive('expenses')} />
            <Tab label="Budgets" active={active === 'budgets'} onClick={() => setActive('budgets')} />
            <Tab label="Courses" active={active === 'shopping'} onClick={() => setActive('shopping')} />
          </div>

          {active === 'dashboard' && (
            <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
              <div className="lg:col-span-2 space-y-6">
                <Card>
                  <div className="flex items-center justify-between">
                    <div>
                      <p className="text-forest-100/70 text-sm">Solde du mois</p>
                      <h2 className="text-3xl font-semibold text-gold-400">{(totalBudgets - totalExpenses).toLocaleString()} DA</h2>
                    </div>
                    <div className="bg-gold-500/15 text-gold-300 px-3 py-1 rounded-full text-xs">+4.2% vs fév.</div>
                  </div>
                  <div className="mt-6 flex gap-3 flex-wrap">
                    <button onClick={addExpense} className="px-4 py-2 rounded-full bg-gold-500 text-forest-900 font-medium">Ajouter dépense</button>
                    <button onClick={addBudget} className="px-4 py-2 rounded-full bg-forest-700 text-forest-100">Créer budget</button>
                    <button onClick={addShopping} className="px-4 py-2 rounded-full bg-forest-700 text-forest-100">Ajouter course</button>
                  </div>
                </Card>

                <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                  <Card className="text-center">
                    <p className="text-forest-100/70 text-sm">💸 Total dépenses</p>
                    <p className="text-2xl font-semibold">{totalExpenses.toLocaleString()} DA</p>
                  </Card>
                  <Card className="text-center">
                    <p className="text-forest-100/70 text-sm">🧮 Budgets alloués</p>
                    <p className="text-2xl font-semibold">{totalBudgets.toLocaleString()} DA</p>
                  </Card>
                  <Card className="text-center">
                    <p className="text-forest-100/70 text-sm">🛒 Courses</p>
                    <p className="text-2xl font-semibold">{shopping.length}</p>
                  </Card>
                </div>

                <Card>
                  <div className="flex items-center justify-between mb-4">
                    <h3 className="text-lg font-semibold">Dépenses par semaine</h3>
                    <span className="text-forest-100/70 text-sm">Mars</span>
                  </div>
                  <div className="flex items-end gap-3 h-32">
                    {[40, 65, 30, 80, 55, 90].map((h, idx) => (
                      <div key={idx} className="flex-1 bg-forest-700/70 rounded-xl relative">
                        <div className="absolute bottom-0 left-0 right-0 bg-gold-500 rounded-xl" style={{ height: `${h}%` }} />
                      </div>
                    ))}
                  </div>
                </Card>
              </div>

              <div className="space-y-6">
                <Card>
                  <h3 className="text-lg font-semibold mb-4">Quick actions</h3>
                  <div className="space-y-3">
                    {[
                      { icon: '⚡', label: 'Payer facture', hint: 'Électricité / Eau' },
                      { icon: '💼', label: 'Ajouter revenu', hint: 'Salaire, bonus' },
                      { icon: '🏦', label: 'Mettre de côté', hint: 'Épargne rapide' },
                    ].map((item, idx) => (
                      <div key={idx} className="bg-forest-700/70 px-4 py-3 rounded-xl flex items-start gap-3">
                        <div className="text-lg">{item.icon}</div>
                        <div>
                          <p className="font-medium">{item.label}</p>
                          <p className="text-forest-100/60 text-sm">{item.hint}</p>
                        </div>
                      </div>
                    ))}
                  </div>
                </Card>

                <Card>
                  <h3 className="text-lg font-semibold mb-4">Dernières dépenses</h3>
                  <ul className="space-y-3 text-sm">
                    {expenses.slice(0, 4).map(e => (
                      <li key={e.id} className="flex justify-between items-center bg-forest-700/60 px-3 py-2 rounded-lg">
                        <span className="text-forest-100">🧾 {e.note}</span>
                        <span className="text-gold-300">{e.amount} DA</span>
                      </li>
                    ))}
                  </ul>
                </Card>
              </div>
            </div>
          )}

          {active === 'expenses' && (
            <div className="space-y-6">
              <Card className="flex items-center justify-between flex-wrap gap-4">
                <div>
                  <h2 className="text-xl font-semibold">Dépenses</h2>
                  <p className="text-forest-100/70">Suivi détaillé des sorties d'argent</p>
                </div>
                <button onClick={addExpense} className="px-4 py-2 rounded-full bg-gold-500 text-forest-900 font-medium">Ajouter dépense</button>
              </Card>

              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                {expenses.map(e => (
                  <Card key={e.id}>
                    <div className="flex items-center justify-between">
                      <div>
                        <p className="text-forest-100/60 text-sm">Catégorie {e.category_id}</p>
                        <p className="text-lg font-semibold">{e.note}</p>
                      </div>
                      <div className="text-gold-400 font-semibold">{e.amount} DA</div>
                    </div>
                    <div className="mt-3 flex justify-between text-xs text-forest-100/50">
                      <span>06 Mar</span>
                      <span>Carte • Maison</span>
                    </div>
                  </Card>
                ))}
              </div>
            </div>
          )}

          {active === 'budgets' && (
            <div className="space-y-6">
              <Card className="flex items-center justify-between flex-wrap gap-4">
                <div>
                  <h2 className="text-xl font-semibold">Budgets</h2>
                  <p className="text-forest-100/70">Pilote tes enveloppes par catégorie</p>
                </div>
                <button onClick={addBudget} className="px-4 py-2 rounded-full bg-gold-500 text-forest-900 font-medium">Ajouter budget</button>
              </Card>

              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                {budgets.map(b => {
                  const used = Math.min(100, Math.round((totalExpenses / (totalBudgets || 1)) * 100));
                  return (
                    <Card key={b.id}>
                      <div className="flex justify-between items-center">
                        <div>
                          <p className="text-forest-100/60 text-sm">Catégorie {b.category_id}</p>
                          <p className="text-lg font-semibold">Budget mensuel</p>
                        </div>
                        <div className="text-gold-400 font-semibold">{b.amount} DA</div>
                      </div>
                      <div className="mt-4">
                        <div className="flex justify-between text-xs text-forest-100/60 mb-2">
                          <span>Utilisé {used}%</span>
                          <span>Reste {(b.amount - totalExpenses / (budgets.length || 1)).toFixed(0)} DA</span>
                        </div>
                        <div className="h-2 bg-forest-700/70 rounded-full">
                          <div className="h-2 bg-gold-500 rounded-full" style={{ width: `${used}%` }} />
                        </div>
                      </div>
                    </Card>
                  );
                })}
              </div>
            </div>
          )}

          {active === 'shopping' && (
            <div className="space-y-6">
              <Card className="flex items-center justify-between flex-wrap gap-4">
                <div>
                  <h2 className="text-xl font-semibold">Liste de courses</h2>
                  <p className="text-forest-100/70">Optimise les achats du foyer</p>
                </div>
                <button onClick={addShopping} className="px-4 py-2 rounded-full bg-gold-500 text-forest-900 font-medium">Ajouter item</button>
              </Card>

              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                {shopping.map(i => (
                  <Card key={i.id}>
                    <div className="flex items-center justify-between">
                      <p className="font-medium">{i.name}</p>
                      <span className="text-forest-100/60 text-sm">{i.category}</span>
                    </div>
                  </Card>
                ))}
              </div>
            </div>
          )}
        </div>
      </main>
    </div>
  );
}
