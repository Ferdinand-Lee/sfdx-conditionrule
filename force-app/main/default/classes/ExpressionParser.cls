public class ExpressionParser{
    static final Map<String, Integer> priority = new Map<String, Integer>{
        '(' => 3,
        ')' => 3,
        'AND' => 2,
        'OR' => 1
    };

    public static Boolean accept(SObject record, ConditionRule__c cr){
        Map<String, SObjectField> fieldDescribeMap = Schema.getGlobalDescribe().get(cr.SObjectType__c).getDescribe().fields.getMap();
        Boolean accept = false;
        Map<String, Boolean> rules = new Map<String,Boolean>();
        for(Integer i = 0; i < cr.size__c.intValue(); i++){
            String field = cr.get('Field_' + i + '__c').toString();
            String option = cr.get('Option_' + i + '__c').toString();
            Object value = cr.get('Value_' + i + '__c');
            
            Boolean isNullValue = (value == null);            
            Schema.DescribeFieldResult fdr = fieldDescribeMap.get(String.valueOf(field)).getDescribe();
            Boolean predict = false;
            
            if(fdr.getType() == Schema.DisplayType.BOOLEAN){
                Boolean fieldValue = Boolean.valueOf(record.get(field));
                Boolean inputVlaue = isNullValue ? false : Boolean.valueOf(value);
                predict = fieldValue == inputVlaue;
                if(option == '<>') predict = !predict;
            }

            if(fdr.getType() == Schema.DisplayType.INTEGER){
                Integer fieldValue = Integer.valueOf(record.get(field));
                Integer inputValue = isNullValue ? null : Integer.valueOf(value);
                if(option == '>') predict = fieldValue > inputValue;
                else if(option == '<') predict = fieldValue < inputValue;
                else if(option == '=') predict = fieldValue == inputValue;
                else if(option == '>=') predict = fieldValue >= inputValue;
                else if(option == '<=') predict = fieldValue <= inputValue;
                else if(option == '<>') predict = fieldValue <> inputValue;
            }

            if(fdr.getType() == Schema.DisplayType.PICKLIST ||
               fdr.getType() == Schema.DisplayType.STRING){
                String fieldValue = String.valueOf(record.get(field));
                String inputValue = isNullValue ? null : String.valueOf(value);                
                predict = fieldValue == inputValue;
                if(option == '<>') predict = !predict;
            }

            rules.put(String.valueOf(i + 1), predict);
        }
        accept = evaluate(cr.Logic__c, rules);
        return accept;
    }

    public static Boolean evaluate(String condition, Map<String, Boolean> rules){
        List<String> erversePolish = getReversePolishNotation(condition);
        List<String> stake = new List<String>();
        rules.put('x', true);
        rules.put('y', false);
        for(Integer i = 0; i < erversePolish.size(); i++){
            String str = erversePolish.get(i);
            if(priority.containsKey(str)){
                Boolean b1 = rules.get(stake.remove(stake.size() - 1));
                Boolean b2 = rules.get(stake.remove(stake.size() - 1));
                if(str == 'OR'){
                    stake.add((b1 || b2) ? 'x' : 'y');
                }else if(str == 'AND'){
                    stake.add((b1 && b2) ? 'x' : 'y');
                }
            }else {
                stake.add(str);
            }
        }        
        return rules.get(stake.get(0));
    }

    public static List<String> getReversePolishNotation(String condition){
        List<String> result = new List<String>();
        List<String> operatorStake = new List<String>();
        Pattern logicPattern = Pattern.compile('\\d|(OR)|(AND)|\\(|\\)');
        Matcher logicMatcher= logicPattern.matcher(condition);
        while(logicMatcher.find()){
            String str = logicMatcher.group(0);
            Integer size = operatorStake.size();
            if(priority.containsKey(str)){
                if(str == '(') {

                }else if(str == ')'){
                    if(size > 0) result.add(operatorStake.remove(size - 1));
                }else{
                    if(size == 0){
                        operatorStake.add(str);
                    }else{
                        Integer top = priority.get(operatorStake[size - 1]);
                        Integer current = priority.get(str);
                        if(top > current){
                            result.add(operatorStake.remove(size - 1));
                            operatorStake.add(str);
                        }else{
                            operatorStake.add(str);
                        }
                    }
                }
            }else{
                result.add(str);
            }
        }
        for(Integer i = operatorStake.size() - 1; i >= 0; i--) 
            result.add(operatorStake.get(i));
        return result;
    }
}
