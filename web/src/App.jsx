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

const Modal = ({ isOpen, onClose, title, children }) => {
  if (!isOpen) return null;
  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/60 backdrop-blur-sm">
      <div className="bg-forest-800 border border-forest-700 w-full max-w-md rounded-2xl p-6 shadow-2xl">
        <div className="flex justify-between items-center mb-6">
          <h3 className="text-xl font-semibold text-gold-400">{title}</h3>
          <button onClick={onClose} className="text-forest-300 hover:text-white">✕</button>
        </div>
        {children}
      </div>
    </div>
  );
};

export default function App() {
  const [active, setActive] = useState('dashboard');
  const household_id = 1;

  const [expenses, setExpenses] = useState([]);
  const [budgets, setBudgets] = useState([]);
  const [shopping, setShopping] = useState([]);

  const [modalType, setModalType] = useState(null); // 'expense', 'budget', 'shopping'
  const [formData, setFormData] = useState({});

  const fetchData = async () => {
    try {
      const [ex, bu, sh] = await Promise.all([
        getExpenses({ household_id }),
        getBudgets({ household_id, month: '2026-03' }),
        getShopping({ household_id })
      ]);
      setExpenses(ex.data.data || []);
      setBudgets(bu.data.data || []);
      setShopping(sh.data.data || []);
    } catch (err) {
      console.error("Fetch error:", err);
    }
  };

  useEffect(() => {
    fetchData();
  }, []);

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      if (modalType === 'expense') {
        await createExpense({ ...formData, household_id, category_id: 1, spent_at: new Date().toISOString().split('T')[0] });
      } else if (modalType === 'budget') {
        await createBudget({ ...formData, household_id, category_id: 1, month: '2026-03' });
      } else if (modalType === 'shopping') {
        await createShopping({ ...formData, household_id });
      }
      setModalType(null);
      setFormData({});
      fetchData();
    } catch (err) {
      alert("Erreur lors de l'ajout");
    }
  };

  const totalExpenses = Array.isArray(expenses) ? expenses.reduce((s, e) => s + Number(e.amount || 0), 0) : 0;
  const totalBudgets = Array.isArray(budgets) ? budgets.reduce((s, b) => s + Number(b.amount || 0), 0) : 0;

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
                    <button onClick={() => setModalType('expense')} className="px-4 py-2 rounded-full bg-gold-500 text-forest-900 font-medium">Ajouter dépense</button>
                    <button onClick={() => setModalType('budget')} className="px-4 py-2 rounded-full bg-forest-700 text-forest-100">Créer budget</button>
                    <button onClick={() => setModalType('shopping')} className="px-4 py-2 rounded-full bg-forest-700 text-forest-100">Ajouter course</button>
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
                      <div key={idx} className="bg-forest-700/70 px-4 py-3 rounded-xl flex items-start gap-3 hover:bg-forest-700 cursor-pointer transition">
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
                        <span className="text-forest-100 truncate pr-2">🧾 {e.note}</span>
                        <span className="text-gold-300 whitespace-nowrap">{e.amount} DA</span>
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
                <button onClick={() => setModalType('expense')} className="px-4 py-2 rounded-full bg-gold-500 text-forest-900 font-medium">Ajouter dépense</button>
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
                      <span>{e.spent_at}</span>
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
                <button onClick={() => setModalType('budget')} className="px-4 py-2 rounded-full bg-gold-500 text-forest-900 font-medium">Ajouter budget</button>
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
                <button onClick={() => setModalType('shopping')} className="px-4 py-2 rounded-full bg-gold-500 text-forest-900 font-medium">Ajouter item</button>
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

      <Modal 
        isOpen={!!modalType} 
        onClose={() => setModalType(null)} 
        title={modalType === 'expense' ? 'Ajouter une dépense' : modalType === 'budget' ? 'Créer un budget' : 'Ajouter une course'}
      >
        <form onSubmit={handleSubmit} className="space-y-4">
          {modalType !== 'shopping' ? (
            <>
              <div>
                <label className="block text-sm text-forest-300 mb-1">Montant (DA)</label>
                <input 
                  type="number" required 
                  className="w-full bg-forest-900 border border-forest-700 rounded-xl px-4 py-2 text-gold-300 outline-none focus:border-gold-500"
                  onChange={e => setFormData({...formData, amount: e.target.value})}
                />
              </div>
              <div>
                <label className="block text-sm text-forest-300 mb-1">Note / Description</label>
                <input 
                  type="text" required 
                  className="w-full bg-forest-900 border border-forest-700 rounded-xl px-4 py-2 outline-none focus:border-gold-500"
                  onChange={e => setFormData({...formData, note: e.target.value})}
                />
              </div>
            </>
          ) : (
            <>
              <div>
                <label className="block text-sm text-forest-300 mb-1">Nom de l'article</label>
                <input 
                  type="text" required 
                  className="w-full bg-forest-900 border border-forest-700 rounded-xl px-4 py-2 outline-none focus:border-gold-500"
                  onChange={e => setFormData({...formData, name: e.target.value})}
                />
              </div>
              <div>
                <label className="block text-sm text-forest-300 mb-1">Catégorie</label>
                <input 
                  type="text" required 
                  className="w-full bg-forest-900 border border-forest-700 rounded-xl px-4 py-2 outline-none focus:border-gold-500"
                  onChange={e => setFormData({...formData, category: e.target.value})}
                />
              </div>
            </>
          )}
          <button type="submit" className="w-full bg-gold-500 text-forest-900 font-bold py-3 rounded-xl shadow-lg mt-4">
            Confirmer
          </button>
        </form>
      </Modal>
    </div>
  );
}
