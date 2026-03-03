import React, { useEffect, useState } from 'react';
import { View, Text, TouchableOpacity, ScrollView } from 'react-native';
import { getExpenses, createExpense, getBudgets, createBudget, getShopping, createShopping } from './api';

const Tab = ({ label, active, onPress }) => (
  <TouchableOpacity onPress={onPress} style={{ padding: 10, backgroundColor: active ? '#2563eb' : '#e5e7eb', borderRadius: 8, marginRight: 8 }}>
    <Text style={{ color: active ? '#fff' : '#111827' }}>{label}</Text>
  </TouchableOpacity>
);

export default function App() {
  const [active, setActive] = useState('dashboard');
  const household_id = 1;

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
    <View style={{ flex: 1, padding: 20, paddingTop: 50, backgroundColor: '#f9fafb' }}>
      <Text style={{ fontSize: 24, fontWeight: 'bold' }}>DariBudget</Text>
      <Text style={{ color: '#6b7280', marginBottom: 12 }}>Budget familial intelligent</Text>

      <ScrollView horizontal style={{ marginBottom: 16 }}>
        <Tab label="Dashboard" active={active==='dashboard'} onPress={()=>setActive('dashboard')} />
        <Tab label="Dépenses" active={active==='expenses'} onPress={()=>setActive('expenses')} />
        <Tab label="Budgets" active={active==='budgets'} onPress={()=>setActive('budgets')} />
        <Tab label="Courses" active={active==='shopping'} onPress={()=>setActive('shopping')} />
      </ScrollView>

      <ScrollView>
        {active === 'dashboard' && (
          <View style={{ backgroundColor: '#fff', padding: 16, borderRadius: 12 }}>
            <Text>Résumé Mensuel</Text>
            <Text>Total dépenses: {expenses.reduce((s,e)=>s+Number(e.amount||0),0)} DA</Text>
            <Text>Budgets: {budgets.reduce((s,b)=>s+Number(b.amount||0),0)} DA</Text>
            <Text>Courses: {shopping.length}</Text>
          </View>
        )}

        {active === 'expenses' && (
          <View style={{ backgroundColor: '#fff', padding: 16, borderRadius: 12 }}>
            <TouchableOpacity onPress={addExpense} style={{ backgroundColor:'#2563eb', padding:10, borderRadius:8, marginBottom:10 }}>
              <Text style={{ color:'#fff' }}>Ajouter dépense</Text>
            </TouchableOpacity>
            {expenses.map(e => (
              <Text key={e.id}>{e.note} — {e.amount} DA</Text>
            ))}
          </View>
        )}

        {active === 'budgets' && (
          <View style={{ backgroundColor: '#fff', padding: 16, borderRadius: 12 }}>
            <TouchableOpacity onPress={addBudget} style={{ backgroundColor:'#2563eb', padding:10, borderRadius:8, marginBottom:10 }}>
              <Text style={{ color:'#fff' }}>Ajouter budget</Text>
            </TouchableOpacity>
            {budgets.map(b => (
              <Text key={b.id}>Cat {b.category_id} — {b.amount} DA</Text>
            ))}
          </View>
        )}

        {active === 'shopping' && (
          <View style={{ backgroundColor: '#fff', padding: 16, borderRadius: 12 }}>
            <TouchableOpacity onPress={addShopping} style={{ backgroundColor:'#2563eb', padding:10, borderRadius:8, marginBottom:10 }}>
              <Text style={{ color:'#fff' }}>Ajouter item</Text>
            </TouchableOpacity>
            {shopping.map(i => (
              <Text key={i.id}>{i.name}</Text>
            ))}
          </View>
        )}
      </ScrollView>
    </View>
  );
}
