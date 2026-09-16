const express = require('express');
const cors = require('cors');
const { v4: uuidv4 } = require('uuid');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());

// In-memory storage
const plans = new Map();

// Seed demo data
const seedPlan = {
  id: 'demo-plan-1',
  firstWorkDate: '2015-03-02',
  retirementGoalDate: '2050-12-31',
  targetAssets: 3000000000, // 30억 원
  currentNetWorth: 450000000, // 4.5억 원
  monthlySavings: 2000000, // 200만원
  createdAt: new Date().toISOString(),
  updatedAt: new Date().toISOString()
};
plans.set(seedPlan.id, seedPlan);

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Create or update plan
app.post('/api/plans', (req, res) => {
  try {
    const { id, firstWorkDate, retirementGoalDate, targetAssets, currentNetWorth, monthlySavings } = req.body;
    
    const planId = id || uuidv4();
    const existingPlan = plans.get(planId);
    
    const plan = {
      id: planId,
      firstWorkDate,
      retirementGoalDate,
      targetAssets,
      currentNetWorth,
      monthlySavings: monthlySavings || 0,
      createdAt: existingPlan ? existingPlan.createdAt : new Date().toISOString(),
      updatedAt: new Date().toISOString()
    };
    
    plans.set(planId, plan);
    res.json(plan);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

// Get plan by ID
app.get('/api/plans/:id', (req, res) => {
  const plan = plans.get(req.params.id);
  if (!plan) {
    return res.status(404).json({ error: 'Plan not found' });
  }
  res.json(plan);
});

// Get all plans (for demo)
app.get('/api/plans', (req, res) => {
  res.json(Array.from(plans.values()));
});

// Simulate scenario
app.post('/api/plans/:id/simulate', (req, res) => {
  try {
    const plan = plans.get(req.params.id);
    if (!plan) {
      return res.status(404).json({ error: 'Plan not found' });
    }
    
    const {
      monthlySavingsDelta = 0,
      retirementYearsDelta = 0,
      livingCostPercentageDelta = 0,
      annualReturnRate = 0.05
    } = req.body;
    
    // Calculate simulation result
    const result = calculateSimulation(plan, {
      monthlySavingsDelta,
      retirementYearsDelta,
      livingCostPercentageDelta,
      annualReturnRate
    });
    
    res.json(result);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

/**
 * Simulation calculation
 * Formula:
 * - FV = Future Value of savings
 * - PV = Present Value (current net worth)
 * - PMT = Monthly payment (savings)
 * - r = Monthly return rate (annual / 12)
 * - n = Number of months
 * 
 * FV = PV * (1 + r)^n + PMT * [((1 + r)^n - 1) / r]
 */
function calculateSimulation(plan, scenario) {
  const today = new Date();
  const retirementDate = new Date(plan.retirementGoalDate);
  
  // Adjust retirement date by years delta
  const adjustedRetirementDate = new Date(retirementDate);
  adjustedRetirementDate.setFullYear(adjustedRetirementDate.getFullYear() + scenario.retirementYearsDelta);
  
  // Calculate months until retirement
  const monthsUntilRetirement = Math.max(0, 
    (adjustedRetirementDate.getFullYear() - today.getFullYear()) * 12 +
    (adjustedRetirementDate.getMonth() - today.getMonth())
  );
  
  // Adjusted monthly savings
  const adjustedMonthlySavings = plan.monthlySavings + scenario.monthlySavingsDelta;
  
  // Monthly return rate
  const monthlyRate = scenario.annualReturnRate / 12;
  
  // Calculate projected net worth at retirement
  const presentValue = plan.currentNetWorth;
  let projectedNetWorth;
  
  if (monthlyRate === 0) {
    // Simple case without returns
    projectedNetWorth = presentValue + (adjustedMonthlySavings * monthsUntilRetirement);
  } else {
    // Future value with compound returns
    const pvFuture = presentValue * Math.pow(1 + monthlyRate, monthsUntilRetirement);
    const pmtFuture = adjustedMonthlySavings * (Math.pow(1 + monthlyRate, monthsUntilRetirement) - 1) / monthlyRate;
    projectedNetWorth = pvFuture + pmtFuture;
  }
  
  // Adjust target assets based on living cost change
  const adjustedTargetAssets = plan.targetAssets * (1 + scenario.livingCostPercentageDelta / 100);
  
  // Determine if goal is reachable
  const isReachable = projectedNetWorth >= adjustedTargetAssets;
  
  // Calculate required monthly savings to reach goal
  let requiredMonthlySavings = adjustedMonthlySavings;
  if (!isReachable && monthsUntilRetirement > 0) {
    if (monthlyRate === 0) {
      requiredMonthlySavings = (adjustedTargetAssets - presentValue) / monthsUntilRetirement;
    } else {
      // Solve for PMT: (Target - PV*(1+r)^n) * r / ((1+r)^n - 1)
      const pvFuture = presentValue * Math.pow(1 + monthlyRate, monthsUntilRetirement);
      requiredMonthlySavings = (adjustedTargetAssets - pvFuture) * monthlyRate / (Math.pow(1 + monthlyRate, monthsUntilRetirement) - 1);
    }
    requiredMonthlySavings = Math.max(0, requiredMonthlySavings);
  }
  
  return {
    originalRetirementDate: plan.retirementGoalDate,
    adjustedRetirementDate: adjustedRetirementDate.toISOString().split('T')[0],
    monthsUntilRetirement,
    currentNetWorth: plan.currentNetWorth,
    adjustedMonthlySavings,
    projectedNetWorth: Math.round(projectedNetWorth),
    targetAssets: adjustedTargetAssets,
    isReachable,
    requiredMonthlySavings: Math.round(requiredMonthlySavings),
    shortfall: Math.round(Math.max(0, adjustedTargetAssets - projectedNetWorth)),
    annualReturnRate: scenario.annualReturnRate
  };
}

app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
  console.log(`Seed plan available at: GET /api/plans/demo-plan-1`);
});
