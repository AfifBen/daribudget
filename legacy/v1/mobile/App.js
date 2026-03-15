import React, { useEffect, useState } from 'react';
import { View, Text, TouchableOpacity, ScrollView } from 'react-native';
import { getExpenses, createExpense, getBudgets, createBudget, getShopping, createShopping } from './api';

const colors = {
  green: '#2E7D6B',
  gold: '#F4C443',
  bg: '#F6F8F7',
  card: '#FFFFFF',
  text: '#0f172a',
  muted: '#6b7280',
};

const Tab = ({ label, active, onPress }) => (
  <TouchableOpacity
    onPress={onPress}
    style={{ paddingVertical: 8, paddingHorizontal: 12, borderRadius: 12, backgroundColor: active ? colors.green : '#e5e7eb', marginRight: 8 }}
  >
    <Text style={{ color: active ? '#fff' : '#111827', fontWeight: '700', fontSize: 12 }}>{label}</Text>
  </TouchableOpacity>
);

const Card = ({ children }) => (
  <View style={{ backgroundColor: colors.card, padding: 16, borderRadius: 16, marginBottom: 12, shadowColor:'#000', shadowOpacity:0.06, shadowRadius:10 }}>
    {children}
  </View>
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
    const res = await createShopping({ household_id, name: 'Lait', category: 'Laitier' });
    setShopping([res.data.data, ...shopping]);
  };

  return (
    <View style={{ flex: 1, padding: 20, paddingTop: 50, backgroundColor: colors.bg }}>
      <View style={{ flexDirection:'row', justifyContent:'space-between', alignItems:'center' }}>
        <Text style={{ fontSize: 22, fontWeight: '800', color: colors.green }}>DariBudget</Text>
        <View style={{ backgroundColor: colors.gold, paddingHorizontal: 10, paddingVertical: 4, borderRadius: 999 }}>
          <Text style={{ fontSize: 11, fontWeight:'700' }}>Mars</Text>
        </View>
      </View>

      <ScrollView horizontal style={{ marginVertical: 12 }} showsHorizontalScrollIndicator={false}>
        <Tab label="Dashboard" active={active==='dashboard'} onPress={()=>setActive('dashboard')} />
        <Tab label="Dépenses" active={active==='expenses'} onPress={()=>setActive('expenses')} />
        <Tab label="Budgets" active={active==='budgets'} onPress={()=>setActive('budgets')} />
        <Tab label="Courses" active={active==='shopping'} onPress={()=>setActive('shopping')} />
      </ScrollView>

      <ScrollView>
        {active === 'dashboard' && (
          <>
            <Card>
              <Text style={{ color: colors.muted, fontSize: 12 }}>Solde du mois</Text>
              <Text style={{ fontSize: 22, fontWeight:'800' }}>68,450 DA</Text>
              <Text style={{ color: colors.muted, fontSize: 12 }}>+12% vs mois passé</Text>
            </Card>
            <View style={{ flexDirection:'row', gap:10 }}>
              <Card><Text style={{ color: colors.muted, fontSize: 12 }}>Dépenses</Text><Text style={{ fontSize:18, fontWeight:'800' }}>31,200</Text></Card>
              <Card><Text style={{ color: colors.muted, fontSize: 12 }}>Budgets</Text><Text style={{ fontSize:18, fontWeight:'800' }}>50,000</Text></Card>
            </View>
            <Card>
              <Text style={{ fontWeight:'700' }}>Prévision mois prochain</Text>
              <Text>Alimentaire — 18,000</Text>
              <Text>Transport — 6,000</Text>
              <Text>Éducation — 8,000</Text>
            </Card>
            <Card>
              <Text style={{ fontWeight:'700' }}>Dépenses anormales</Text>
              <Text style={{ color: colors.muted }}>Supermarché +35% cette semaine</Text>
            </Card>
          </>
        )}

        {active === 'expenses' && (
          <Card>
            <TouchableOpacity onPress={addExpense} style={{ backgroundColor: colors.green, padding:10, borderRadius:12, marginBottom:10 }}>
              <Text style={{ color:'#fff', fontWeight:'700' }}>Ajouter dépense</Text>
            </TouchableOpacity>
            {expenses.map(e => (
              <Text key={e.id}>{e.note} — {e.amount} DA</Text>
            ))}
          </Card>
        )}

        {active === 'budgets' && (
          <Card>
            <TouchableOpacity onPress={addBudget} style={{ backgroundColor: colors.green, padding:10, borderRadius:12, marginBottom:10 }}>
              <Text style={{ color:'#fff', fontWeight:'700' }}>Ajouter budget</Text>
            </TouchableOpacity>
            {budgets.map(b => (
              <Text key={b.id}>Cat {b.category_id} — {b.amount} DA</Text>
            ))}
          </Card>
        )}

        {active === 'shopping' && (
          <Card>
            <TouchableOpacity onPress={addShopping} style={{ backgroundColor: colors.green, padding:10, borderRadius:12, marginBottom:10 }}>
              <Text style={{ color:'#fff', fontWeight:'700' }}>Ajouter item</Text>
            </TouchableOpacity>
            {shopping.map(i => (
              <Text key={i.id}>{i.name} — {i.category || 'Autre'}</Text>
            ))}
            <Text style={{ marginTop:10, color: colors.muted }}>Catégories: Laitier · Viandes · Détergent · Légumes</Text>
          </Card>
        )}
      </ScrollView>
    </View>
  );
}
